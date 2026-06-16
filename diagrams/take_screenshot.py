import os
import sys
import time

# Memastikan library Playwright terinstall secara otomatis
try:
    from playwright.sync_api import sync_playwright
except ImportError:
    print("[*] Library 'playwright' belum terpasang. Sedang memasang...")
    os.system(f"{sys.executable} -m pip install playwright")
    os.system("playwright install chromium")
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("[x] Gagal memasang playwright secara otomatis. Silakan jalankan manual:")
        print("    pip install playwright && playwright install chromium")
        sys.exit(1)

# Memastikan library Pillow terinstall secara otomatis untuk manipulasi gambar
try:
    from PIL import Image
except ImportError:
    print("[*] Library 'Pillow' (PIL) belum terpasang. Sedang memasang...")
    os.system(f"{sys.executable} -m pip install pillow")
    try:
        from PIL import Image
    except ImportError:
        print("[x] Gagal memasang Pillow secara otomatis. Silakan jalankan manual:")
        print("    pip install pillow")
        sys.exit(1)

def is_bg_color(pixel, tolerance=8):
    # Background color Flutter Anda: #F7F9FB -> RGB (247, 249, 251)
    # Menghandel format RGB maupun RGBA
    r, g, b = pixel[:3]
    return abs(r - 247) <= tolerance and abs(g - 249) <= tolerance and abs(b - 251) <= tolerance

def is_row_blank(img, y, width, tolerance=8):
    # Periksa beberapa titik koordinat X secara horizontal untuk memastikan baris kosong
    x_ratios = [0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95]
    for ratio in x_ratios:
        x = int(width * ratio)
        if not is_bg_color(img.getpixel((x, y)), tolerance):
            return False
    return True

def crop_empty_gap(image_path, output_path, width):
    print("[*] Menganalisis gambar untuk mendeteksi gap kosong...")
    img = Image.open(image_path)
    img_width, img_height = img.size
    
    # Cek apakah baris paling bawah adalah background kosong (menandakan tidak ada Bottom Nav Bar)
    # Ini sangat berguna untuk halaman detail / sub-halaman
    has_nav_bar = not is_row_blank(img, img_height - 5, img_width)
    
    y_nav_top = None
    y_content_bottom = None
    
    if not has_nav_bar:
        # Halaman Detail / Sub-halaman (Tanpa Bottom Nav Bar)
        print("[*] Mengidentifikasi halaman sebagai Halaman Detail (Tanpa Bottom Nav Bar)...")
        for y in range(img_height - 1, -1, -1):
            if not is_row_blank(img, y, img_width):
                y_content_bottom = y
                break
        if y_content_bottom is not None:
            padding = 16
            y_content_end = min(y_content_bottom + padding, img_height)
            gap_height = img_height - y_content_end
            if gap_height > 20:
                print(f"[v] Memotong gap kosong bawah sebesar {gap_height}px...")
                cropped = img.crop((0, 0, img_width, y_content_end))
                cropped.save(output_path)
                return True
        return False
        
    else:
        # Halaman Utama (Dengan Bottom Nav Bar)
        print("[*] Mengidentifikasi halaman sebagai Halaman Utama (Dengan Bottom Nav Bar)...")
        # 1. Cari batas atas Bottom Navigation Bar (mencari baris kosong pertama dari bawah)
        for y in range(img_height - 10, -1, -1):
            if is_row_blank(img, y, img_width):
                y_nav_top = y + 1
                break
                
        if y_nav_top is None:
            print("[!] Bottom Navigation Bar tidak terdeteksi. Menyimpan screenshot asli.")
            return False
            
        # 2. Cari batas bawah dari konten (mencari baris non-kosong pertama di atas y_nav_top)
        # Kita berikan margin aman sebesar 20 piksel di atas y_nav_top untuk menghindari shadow/border/antialiasing dari nav bar
        start_y = max(y_nav_top - 20, 0)
        for y in range(start_y, -1, -1):
            if not is_row_blank(img, y, img_width):
                y_content_bottom = y
                break
                
        if y_content_bottom is None:
            print("[!] Konten utama tidak terdeteksi. Menyimpan screenshot asli.")
            return False
            
        # Tambahkan padding aman di bawah konten (misal 16 piksel) agar tidak terlalu mepet
        padding = 16
        y_content_end = min(y_content_bottom + padding, y_nav_top)
        
        gap_height = y_nav_top - y_content_end
        
        # Jika gap kosong cukup besar, lakukan pemotongan dan penyambungan
        if gap_height > 20:
            print(f"[v] Terdeteksi gap kosong sebesar {gap_height}px.")
            print("[*] Memotong gap kosong dan merapatkan Bottom Navigation Bar...")
            
            # Potong bagian konten (atas)
            content_box = (0, 0, img_width, y_content_end)
            content_part = img.crop(content_box)
            
            # Potong bagian navigation bar (bawah)
            nav_box = (0, y_nav_top, img_width, img_height)
            nav_part = img.crop(nav_box)
            
            # Gabungkan keduanya ke dalam image baru
            new_height = content_part.height + nav_part.height
            combined_img = Image.new("RGBA", (img_width, new_height))
            combined_img.paste(content_part, (0, 0))
            combined_img.paste(nav_part, (0, content_part.height))
            
            # Simpan hasil akhir
            combined_img.save(output_path)
            print(f"[v] Screenshot berhasil dirapatkan!")
            return True
        else:
            print("[*] Gap kosong tidak signifikan. Menyimpan screenshot asli.")
            return False

def capture_screenshot(url, width=420, max_height=2000, output_path="screenshot.png", tab_index=0, click_targets=None):
    if click_targets is None:
        click_targets = []
        
    temp_path = output_path.replace(".png", "_temp.png")
    
    print(f"[*] Menjalankan browser Headless Chromium...")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        # Buka dengan tinggi maksimal agar semua konten ter-render di viewport besar
        page = browser.new_page(viewport={"width": width, "height": max_height})
        
        print(f"[*] Membuka URL: {url}")
        page.goto(url)
        
        print(f"[*] Menunggu Flutter selesai me-load UI (5 detik)...")
        time.sleep(5)
        
        # Jika bukan tab pertama (Overview), lakukan simulasi klik pada tab yang dipilih
        if tab_index > 0:
            # Lebar bottom navigation bar dibagi 4 secara rata (Overview, Projects, Staff, Reports)
            tab_width = width / 4
            click_x = (tab_index * tab_width) + (tab_width / 2)
            # Klik 30 piksel dari bawah viewport untuk menekan tombol menu navigasi
            click_y = max_height - 30
            
            print(f"[*] Mengklik tab menu navigasi (Koordinat X: {click_x:.1f}, Y: {click_y})...")
            page.mouse.click(click_x, click_y)
            
            print("[*] Menunggu konten halaman tab selesai dirender (3 detik)...")
            time.sleep(3)
            
        # Lakukan simulasi klik pada elemen teks untuk navigasi ke halaman detail secara dinamis
        for target in click_targets:
            print(f"[*] Mencari dan mengklik elemen dengan teks: '{target}'...")
            try:
                # Cek jika elemen ada di semantics tree dan klik
                # Kita set timeout 5 detik agar tidak menggantung jika elemen tidak ditemukan
                element = page.get_by_text(target).first
                element.click(timeout=5000)
                print(f"[v] Elemen '{target}' berhasil diklik.")
                time.sleep(2)  # Beri waktu 2 detik untuk animasi transisi
            except Exception as e:
                print(f"[!] Gagal mengklik '{target}' lewat get_by_text: {e}")
                print("[*] Mencoba mencari menggunakan selector teks alternatif...")
                try:
                    page.locator(f"text={target}").first.click(timeout=5000)
                    print(f"[v] Elemen '{target}' berhasil diklik (alternatif).")
                    time.sleep(2)
                except Exception as e2:
                    print(f"[x] Tetap gagal mengklik '{target}': {e2}")
        
        print(f"[*] Mengambil screenshot mentah (420x{max_height})...")
        page.screenshot(path=temp_path)
        browser.close()
        
    # Lakukan deteksi gap dan crop otomatis
    success = False
    try:
        success = crop_empty_gap(temp_path, output_path, width)
    except Exception as e:
        print(f"[!] Gagal memproses gambar otomatis: {e}")
        
    # Hapus file temporary dan pastikan file final siap
    if os.path.exists(temp_path):
        if not success:
            # Jika crop gagal/tidak perlu, ganti nama file temp menjadi output utama
            if os.path.exists(output_path):
                os.remove(output_path)
            os.rename(temp_path, output_path)
        else:
            os.remove(temp_path)
            
    print(f"[v] Sukses! File akhir disimpan di: {os.path.abspath(output_path)}")

if __name__ == "__main__":
    default_url = "http://localhost:54007/"
    
    print("=" * 50)
    print("   BOT AUTO-SCREENSHOT & AUTO-CROP FLUTTER WEB")
    print("=" * 50)
    
    url = input(f"Masukkan URL web Flutter [{default_url}]: ").strip()
    if not url:
        url = default_url
        
    width_input = input("Masukkan lebar / width screenshot [420]: ").strip()
    width = int(width_input) if width_input else 420
    
    print("\nPilih Tab Halaman awal:")
    print("1. Overview (Dashboard)")
    print("2. Projects")
    print("3. Staff")
    print("4. Reports")
    tab_choice = input("Pilihan [1-4, default 1]: ").strip()
    
    tab_index = 0
    if tab_choice in ["1", "2", "3", "4"]:
        tab_index = int(tab_choice) - 1
        
    # Minta input untuk elemen-elemen teks yang ingin diklik secara berurutan
    print("\n--- SIMULASI KLIK DETAIL (DINAMIS) ---")
    print("Masukkan teks elemen yang ingin diklik secara berurutan untuk masuk ke halaman detail.")
    print("Pisahkan dengan koma jika lebih dari satu (contoh: Kepala, Active Tasks).")
    print("Kosongkan jika ingin langsung screenshot halaman utama tab.")
    click_input = input("Teks elemen untuk diklik: ").strip()
    
    click_targets = []
    if click_input:
        click_targets = [t.strip() for t in click_input.split(",") if t.strip()]
        
    # Default nama file berdasarkan tab dan target klik
    tab_names = ["overview", "projects", "staff", "reports"]
    default_filename = tab_names[tab_index]
    if click_targets:
        clean_targets = "_".join([t.lower().replace(" ", "_").replace(":", "").replace("/", "") for t in click_targets])
        default_filename += f"_{clean_targets}"
    default_filename += ".png"
    
    output_filename = input(f"Nama file hasil screenshot [{default_filename}]: ").strip()
    if not output_filename:
        output_filename = default_filename
        
    if not output_filename.endswith(".png"):
        output_filename += ".png"
        
    script_dir = os.path.dirname(os.path.abspath(__file__))
    final_output_path = os.path.join(script_dir, output_filename)
    
    try:
        # Kita buat max_height cukup besar (2000px) agar semua konten tertampung
        capture_screenshot(url, width, 2000, final_output_path, tab_index=tab_index, click_targets=click_targets)
    except Exception as e:
        print(f"\n[x] Terjadi error: {e}")
        print("Pastikan server Flutter Web Anda sudah berjalan sebelum menjalankan script ini.")

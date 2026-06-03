import os
import re
import json
import zlib
import base64
import urllib.request
import urllib.error
import sys

def print_status(msg, status_type="info"):
    colors = {
        "success": "[v]",
        "error": "[x]",
        "info": "[*]",
        "warning": "[!]"
    }
    prefix = colors.get(status_type, "[*]")
    # Gunakan print standar tanpa karakter unicode khusus untuk menghindari UnicodeEncodeError pada terminal Windows
    print(f"{prefix} {msg}")

def encode_mermaid(mermaid_code):
    # Membersihkan karakter return carriage jika ada
    mermaid_code = mermaid_code.strip().replace('\r\n', '\n')
    
    # Format State JSON yang kompatibel dengan Mermaid Live Editor
    state = {
        "code": mermaid_code,
        "mermaid": {"theme": "default"}
    }
    
    json_bytes = json.dumps(state).encode('utf-8')
    
    # Kompres dengan zlib (pako deflate standar, wbits=15)
    compressor = zlib.compressobj(9, zlib.DEFLATED, 15, 8, zlib.Z_DEFAULT_STRATEGY)
    compressed = compressor.compress(json_bytes) + compressor.flush()
    
    # Encode ke base64
    b64_encoded = base64.b64encode(compressed).decode('ascii')
    
    # URL safe replacement yang wajib digunakan oleh pako / mermaid.live
    url_safe_b64 = b64_encoded.replace('+', '-').replace('/', '_').rstrip('=')
    
    return f"pako:{url_safe_b64}"

def convert_md_file(file_path):
    print_status(f"Membaca {os.path.basename(file_path)}...", "info")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Cari blok ```mermaid ... ```
    # Mendukung jika penutup ``` tidak ada (mengambil sampai akhir file)
    mermaid_blocks = re.findall(r'```mermaid\s*\n(.*?)(?:\n```|$)', content, re.DOTALL)
    
    if not mermaid_blocks:
        print_status(f"Tidak ditemukan diagram Mermaid di dalam {os.path.basename(file_path)}.", "warning")
        return
        
    base_dir = os.path.dirname(file_path)
    # Tentukan folder output bernama 'mermaid-png' di dalam direktori file .md
    output_dir = os.path.join(base_dir, "mermaid-png")
    os.makedirs(output_dir, exist_ok=True)
    
    file_name_without_ext = os.path.splitext(os.path.basename(file_path))[0]
    
    # Bersihkan blocks yang kosong
    valid_blocks = [b.strip() for b in mermaid_blocks if b.strip()]
    
    if not valid_blocks:
        print_status(f"Tidak ditemukan diagram Mermaid yang valid di dalam {os.path.basename(file_path)}.", "warning")
        return
        
    for idx, block in enumerate(valid_blocks):
        # Tentukan nama file output PNG di dalam folder 'mermaid-png'
        if len(valid_blocks) == 1:
            output_png_path = os.path.join(output_dir, f"{file_name_without_ext}.png")
        else:
            output_png_path = os.path.join(output_dir, f"{file_name_without_ext}_{idx+1}.png")
            
        print_status(f"Ditemukan diagram #{idx+1}. Mengirimkan ke API renderer (transparan)...", "info")
        
        try:
            encoded_str = encode_mermaid(block)
            url = f"https://mermaid.ink/img/{encoded_str}?type=png"
            
            # Request dengan User-Agent agar tidak diblokir
            req = urllib.request.Request(
                url, 
                headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
            )
            
            with urllib.request.urlopen(req) as response:
                image_data = response.read()
                
            with open(output_png_path, 'wb') as out_file:
                out_file.write(image_data)
                
            print_status(f"Berhasil mengonversi diagram! Disimpan ke: mermaid-png/{os.path.basename(output_png_path)}", "success")
            
        except urllib.error.HTTPError as e:
            print_status(f"Gagal mengunduh gambar diagram #{idx+1}: HTTP {e.code} - {e.reason}", "error")
        except Exception as e:
            print_status(f"Gagal mengonversi diagram #{idx+1}: {str(e)}", "error")

def main():
    print("\n" + "="*50)
    print("      MERMAID MD TO PNG OFFLINE CONVERTER")
    print("="*50 + "\n")
    
    current_dir = os.path.dirname(os.path.abspath(__file__))
    md_files = [f for f in os.listdir(current_dir) if f.endswith('.md')]
    
    if not md_files:
        print_status("Tidak ada file .md di direktori ini.", "warning")
        return
        
    print_status(f"Menemukan {len(md_files)} file .md di direktori saat ini.\n", "info")
    
    for md_file in md_files:
        full_path = os.path.join(current_dir, md_file)
        convert_md_file(full_path)
        print("-" * 40)

if __name__ == "__main__":
    main()

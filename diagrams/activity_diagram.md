# 🔄 Activity Diagram - Smart Tagihan (Seluruh Kasus Penggunaan)

Laporan ini memuat rancangan **Activity Diagram** komprehensif yang mencakup **seluruh kasus penggunaan (use cases)** di dalam sistem pendukung keputusan pembayaran tagihan **Smart Tagihan**.

---

## 1. Alur Aktivitas: Login, Sesi, dan Proteksi Idle Timeout

Menggambarkan alur masuk pengguna ke dalam sistem, pembentukan sesi, serta mekanisme pengamanan sesi otomatis (*idle timeout*) berdasarkan aktivitas pengguna.

```mermaid
flowchart TD
    start_session([Mulai]) --> access_page[Akses Sistem Smart Tagihan]
    access_page --> check_cookie{Apakah memiliki cookie 'remember me'?}
    
    check_cookie -- "Ya" --> auto_restore[Kembalikan Sesi Login Pengguna]
    check_cookie -- "Tidak" --> show_login_form[Tampilkan Form Login]
    
    show_login_form --> input_credentials[Masukkan Username & Password]
    input_credentials --> submit_login[Klik Tombol Login]
    submit_login --> verify_credentials{Verifikasi di Database}
    
    verify_credentials -- "Kredensial Salah" --> show_error[Tampilkan Alert: 'Username/Password Salah']
    show_error --> show_login_form
    
    verify_credentials -- "Kredensial Benar" --> create_session[Bentuk Sesi Pengguna & Catat Waktu Aktivitas Terakhir]
    auto_restore --> create_session
    
    create_session --> go_dashboard[Buka Halaman Dashboard]
    
    go_dashboard --> user_activity{Apakah terdapat aktivitas pengguna?}
    
    user_activity -- "Tidak (Idle)" --> check_timeout{Apakah waktu idle melebihi batas?}
    check_timeout -- "Tidak" --> user_activity
    check_timeout -- "Ya" --> destroy_session[Hapus Sesi & Cookie Pengguna]
    destroy_session --> redirect_login[Dialihkan ke Login dengan Pesan Timeout]
    redirect_login --> show_login_form
    
    user_activity -- "Ya (Klik/Akses Menu)" --> update_last_activity[Perbarui Waktu Aktivitas Terakhir]
    update_last_activity --> process_action[Proses Aksi Pengguna]
    
    process_action --> is_logout{Apakah memilih logout?}
    is_logout -- "Ya" --> destroy_session
    is_logout -- "Tidak" --> user_activity
```

---

## 2. Alur Aktivitas: Pengelolaan Data Tagihan Secara Manual (CRUD)

Menggambarkan alur bisnis bagaimana pengguna melakukan penambahan, pembaruan (edit), dan penghapusan data tagihan secara manual.

```mermaid
flowchart TD
    start_crud([Mulai]) --> enter_tagihan_page[Masuk ke Halaman Data Tagihan]
    
    enter_tagihan_page --> choose_action{Pilih Aksi Pengelolaan}
    
    %% CASE A: TAMBAH DATA
    choose_action -- "Tambah Manual" --> input_manual_form[Isi Form: Vendor, No Tagihan, Nilai, Tanggal, TOP]
    input_manual_form --> click_save[Klik Tombol Simpan Tagihan]
    click_save --> validate_manual{Validasi Kelengkapan Data}
    
    validate_manual -- "Ada field kosong / nilai <= 0" --> show_alert_invalid[Tampilkan Alert Validasi Gagal]
    show_alert_invalid --> input_manual_form
    
    validate_manual -- "Data Valid" --> calc_due_manual[Hitung Tanggal Jatuh Tempo Hari Kerja]
    calc_due_manual --> map_sub_manual[Tentukan Kategori Urgensi & Risiko sub-kriteria]
    map_sub_manual --> insert_tagihan_db[Simpan ke Tabel Tagihan]
    insert_tagihan_db --> log_audit_insert[Catat ke Tabel Audit Log: INSERT]
    log_audit_insert --> reset_session_calc[Reset Flag Perhitungan Sesi]
    reset_session_calc --> show_success_alert[Tampilkan Alert Sukses]
    show_success_alert --> reload_tagihan[Segarkan Halaman & Filter Bulan Baru]
    
    %% CASE B: EDIT DATA
    choose_action -- "Edit Tagihan" --> click_edit_btn[Klik Tombol Edit Tagihan]
    click_edit_btn --> fetch_old_data[Ambil Data Lama dari Database]
    fetch_old_data --> show_edit_modal[Tampilkan Modal Edit Tagihan]
    show_edit_modal --> modify_fields[Ubah Nilai Bidang Form yang Diinginkan]
    modify_fields --> click_update[Klik Tombol Simpan Perubahan]
    click_update --> validate_edit{Validasi Data Baru}
    
    validate_edit -- "Data Tidak Valid" --> show_alert_edit[Tampilkan Alert Edit Gagal]
    show_alert_edit --> show_edit_modal
    
    validate_edit -- "Data Valid" --> recanc_due[Hitung Ulang Jatuh Tempo & Sub-kriteria]
    recanc_due --> update_tagihan_db[Update ke Tabel Tagihan]
    update_tagihan_db --> log_audit_update[Catat ke Tabel Audit Log: UPDATE]
    log_audit_update --> reset_session_calc
    
    %% CASE C: HAPUS DATA
    choose_action -- "Hapus Tagihan" --> click_delete_btn[Klik Tombol Hapus Tagihan]
    click_delete_btn --> show_confirm[Tampilkan Dialog Konfirmasi Penghapusan]
    show_confirm -- "Batal" --> reload_tagihan
    show_confirm -- "Setuju" --> delete_tagihan_db[Hapus Data Tagihan dari Database]
    delete_tagihan_db --> log_audit_delete[Catat ke Tabel Audit Log: DELETE]
    log_audit_delete --> reset_session_calc
    
    reload_tagihan --> stop_crud([Selesai])
```

---

## 3. Alur Aktivitas: Impor Data Tagihan Massal dari Excel

Menggambarkan alur penambahan data tagihan dalam jumlah besar sekaligus menggunakan file Excel template.

```mermaid
flowchart TD
    start_import([Mulai]) --> open_tagihan[Buka Halaman Data Tagihan]
    open_tagihan --> upload_excel[Pilih Berkas Excel .xlsx/.xls]
    upload_excel --> click_upload[Klik Upload & Import]
    
    click_upload --> parse_excel{Membaca & Parsing Berkas}
    
    parse_excel -- "Format Kolom Salah / Data Kosong" --> show_err[Tampilkan Alert Detail Baris Error]
    show_err --> upload_excel
    
    parse_excel -- "Struktur Sesuai" --> start_transaction[Buka Transaksi Database]
    start_transaction --> loop_rows[Perulangan Tiap Baris Data]
    
    loop_rows --> calc_due_import[Kalkulasi Jatuh Tempo otomatis berdasarkan Hari Kerja]
    calc_due_import --> map_sub_import[Petakan Kategori Urgensi & Risiko ke Sub-Kriteria]
    map_sub_import --> save_db_import[Simpan Tagihan ke Database]
    save_db_import --> write_audit_import[Catat Aksi ke Audit Log: INSERT]
    
    write_audit_import --> check_next{Apakah ada baris berikutnya?}
    check_next -- "Ya" --> loop_rows
    check_next -- "Tidak" --> check_errors{Apakah terdapat baris galat?}
    
    check_errors -- "Ya (Sebagian/Seluruhnya Galat)" --> rollback_db[Rollback Transaksi Database]
    rollback_db --> show_partial_alert[Tampilkan Alert Detail Baris yang Bermasalah]
    show_partial_alert --> upload_excel
    
    check_errors -- "Tidak (Semua Baris Valid)" --> commit_db[Commit Transaksi Database]
    commit_db --> show_success_import[Tampilkan Alert Sukses Impor]
    show_success_import --> reset_cache_import[Reset Sesi Perhitungan Aktif]
    reset_cache_import --> stop_import([Selesai])
```

---

## 4. Alur Aktivitas: Pengelolaan Parameter Kriteria & Sub-Kriteria SMART

Menggambarkan alur bagaimana administrator melakukan konfigurasi bobot dan tipe kriteria (Benefit/Cost) serta skala sub-kriteria.

```mermaid
flowchart TD
    start_param([Mulai]) --> select_menu{Pilih Menu Parameter}
    
    %% KRITERIA
    select_menu -- "Data Kriteria" --> open_kriteria[Buka Halaman Data Kriteria]
    open_kriteria --> view_kriteria[Lihat Daftar Kriteria SMART]
    view_kriteria --> choose_kriteria_action{Pilih Aksi Kriteria}
    
    choose_kriteria_action -- "Tambah Kriteria" --> input_kriteria_form[Isi: Kode, Nama, Tipe, Bobot]
    input_kriteria_form --> click_save_krit[Klik Simpan Kriteria]
    click_save_krit --> insert_kriteria_db[Simpan ke Tabel Kriteria]
    
    choose_kriteria_action -- "Edit Kriteria" --> open_edit_modal_krit[Klik Edit & Tampilkan Modal]
    open_edit_modal_krit --> modify_kriteria[Ubah Nama, Tipe, atau Bobot]
    modify_kriteria --> click_update_krit[Klik Tombol Update]
    click_update_krit --> update_kriteria_db[Update Tabel Kriteria]
    
    choose_kriteria_action -- "Hapus Kriteria" --> click_delete_krit[Klik Hapus Kriteria]
    click_delete_krit --> confirm_delete_krit{Konfirmasi Hapus?}
    confirm_delete_krit -- "Ya" --> delete_kriteria_db[Hapus dari Tabel Kriteria]
    confirm_delete_krit -- "Tidak" --> reload_kriteria
    
    insert_kriteria_db --> reload_kriteria[Segarkan Halaman Kriteria]
    update_kriteria_db --> reload_kriteria
    delete_kriteria_db --> reload_kriteria
    
    %% SUB KRITERIA
    select_menu -- "Data Sub-Kriteria" --> open_sub_kriteria[Buka Halaman Data Sub-Kriteria]
    open_sub_kriteria --> navigate_tabs[Pilih Tab Kriteria C1 - C4]
    navigate_tabs --> view_sub_kriteria[Lihat Daftar Sub-Kriteria terpilih]
    view_sub_kriteria --> choose_sub_action{Pilih Aksi Sub-Kriteria}
    
    choose_sub_action -- "Tambah Sub-kriteria" --> input_sub_form[Isi: Kode Sub, Nama, Nilai Skala]
    input_sub_form --> click_save_sub[Klik Simpan]
    click_save_sub --> insert_sub_db[Simpan ke Tabel Sub-Kriteria]
    
    choose_sub_action -- "Edit Sub-kriteria" --> open_edit_modal_sub[Klik Edit & Tampilkan Modal]
    open_edit_modal_sub --> modify_sub[Ubah Nama Sub-Kriteria / Nilai Skala]
    modify_sub --> click_update_sub[Klik Simpan Perubahan]
    click_update_sub --> update_sub_db[Update Tabel Sub-Kriteria]
    
    choose_sub_action -- "Hapus Sub-kriteria" --> click_delete_sub[Klik Hapus]
    click_delete_sub --> confirm_delete_sub{Konfirmasi Hapus?}
    confirm_delete_sub -- "Ya" --> delete_sub_db[Hapus dari Tabel Sub-Kriteria]
    confirm_delete_sub -- "Tidak" --> reload_sub
    
    insert_sub_db --> reload_sub[Segarkan Halaman Sub-Kriteria]
    update_sub_db --> reload_sub
    delete_sub_db --> reload_sub
    
    reload_kriteria --> stop_param([Selesai])
    reload_sub --> stop_param
```

---

## 5. Alur Aktivitas: Proses Eksekusi Perhitungan SMART

Menggambarkan alur simulasi pengambilan keputusan SMART yang memproses seluruh kriteria dan menghasilkan urutan prioritas pembayaran vendor.

```mermaid
flowchart TD
    start_calc([Mulai]) --> open_calc_page[Buka Halaman Perhitungan SMART]
    open_calc_page --> select_period[Pilih Periode Bulan & Tahun]
    select_period --> click_calc[Klik Tombol Hitung Sekarang]
    
    click_calc --> query_tagihan[Ambil Data Tagihan untuk Periode Terpilih]
    query_tagihan --> check_data_exists{Apakah data tagihan ada?}
    
    check_data_exists -- "Tidak Ada" --> show_empty_alert[Tampilkan Pesan: Data Periode Terpilih Kosong]
    show_empty_alert --> select_period
    
    check_data_exists -- "Ada Data" --> query_active_criteria[Ambil Konfigurasi Bobot & Tipe Kriteria dari DB]
    
    query_active_criteria --> calc_min_max[Cari Nilai Minimum & Maksimum tiap kriteria tagihan aktif]
    
    calc_min_max --> loop_tagihan[Perulangan Kalkulasi per Tagihan]
    
    %% SMART ALGORITHM COMPUTATION
    loop_tagihan --> calc_util_c1[Hitung Utility C1 (Nominal Tagihan):<br>Tipe Cost = max-val / max-min]
    calc_util_c1 --> check_c2_tipe{Cek Tipe Kriteria C2}
    
    check_c2_tipe -- "Cost (Aktif)" --> calc_util_c2_cost[Hitung Utility C2 (Jatuh Tempo):<br>Tipe Cost = max-val / max-min]
    check_c2_tipe -- "Benefit" --> calc_util_c2_benefit[Hitung Utility C2 (Jatuh Tempo):<br>Tipe Benefit = val-min / max-min]
    
    calc_util_c2_cost --> calc_util_c3[Hitung Utility C3 (Urgensi):<br>Tipe Benefit = val-min / max-min]
    calc_util_c2_benefit --> calc_util_c3
    
    calc_util_c3 --> calc_util_c4[Hitung Utility C4 (Risiko):<br>Tipe Benefit = val-min / max-min]
    
    calc_util_c4 --> restrict_range[Batasi Seluruh Nilai Utility di range 0.0 s.d 1.0]
    
    restrict_range --> sum_score[Hitung Skor Akhir = jumlah perkalian utility x bobot kriteria]
    
    sum_score --> check_loop_next{Apakah ada tagihan berikutnya?}
    check_loop_next -- "Ya" --> loop_tagihan
    
    check_loop_next -- "Tidak" --> sort_ranking[Urutkan Tagihan Descending menurut Skor Akhir]
    
    sort_ranking --> check_history_db{Cek apakah riwayat periode ini telah tersimpan hari ini?}
    check_history_db -- "Ya" --> update_history_db[Update baris Riwayat Perhitungan: hasil_json]
    check_history_db -- "Tidak" --> insert_history_db[Insert baris baru Riwayat Perhitungan: hasil_json]
    
    update_history_db --> save_session_active[Simpan Data & Periode ke Variabel Sesi Aktif]
    insert_history_db --> save_session_active
    
    save_session_active --> render_accordion_steps[Renders Tampilan Accordion Interaktif 8-Langkah]
    render_accordion_steps --> stop_calc([Selesai])
```

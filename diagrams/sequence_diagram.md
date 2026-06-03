# 🎬 Sequence Diagram - Smart Tagihan

Sequence Diagram menggambarkan interaksi antar komponen sistem secara berurutan berdasarkan waktu ketika mengeksekusi operasi bisnis. Diagram di bawah menyajikan interaksi untuk proses **Unggah Tagihan Excel** dan **Perhitungan SMART**.

---

## A. Interaksi Proses: Unggah Data Tagihan Excel

```mermaid
sequenceDiagram
    autonumber
    actor Admin as Administrator
    participant UI as tagihan.php (View)
    participant Lib as PhpSpreadsheet (Parser)
    participant Log as audit_log.php (Helper)
    participant DB as MySQL Database

    Admin->>UI: Unggah Berkas Excel (.xlsx) & Klik Upload
    activate UI
    
    UI->>Lib: load(temp_file)
    activate Lib
    Lib-->>UI: spreadsheet object
    deactivate Lib
    
    UI->>Lib: toArray()
    activate Lib
    Lib-->>UI: data baris array
    deactivate Lib
    
    UI->>DB: START TRANSACTION
    
    loop Per baris data (mulai baris kedua)
        UI->>UI: Validasi data wajib & format tanggal
        UI->>UI: hitungHariKerja(tgl_dokumen, top_hari)
        UI->>UI: Tentukan ID Urgensi & Risiko (Sub-kriteria)
        
        UI->>DB: INSERT INTO tagihan (vendor, no_tagihan, nilai_tagihan, tanggal_dokumen, top, jatuh_tempo, id_urgensi, id_risiko)
        activate DB
        DB-->>UI: last_inserted_id
        deactivate DB
        
        UI->>Log: createInsertDetails(vendor, no_tagihan, nilai, tanggal, top, top_hari)
        activate Log
        Log-->>UI: json_details_string
        deactivate Log
        
        UI->>Log: logAudit(conn, 'INSERT', id_tagihan, json_details)
        activate Log
        Log->>DB: INSERT INTO audit_log (...)
        Log-->>UI: success
        deactivate Log
    end
    
    alt Sukses tanpa galat
        UI->>DB: COMMIT
        UI-->>Admin: Alert: 'Import berhasil!' & Halaman diperbarui
    else Terdapat baris galat (error)
        UI->>DB: ROLLBACK
        UI-->>Admin: Alert: 'Import gagal!' & Detail letak baris galat
    end
    deactivate UI
```

---

## B. Interaksi Proses: Eksekusi Perhitungan SMART

```mermaid
sequenceDiagram
    autonumber
    actor User as Pengguna / Admin
    participant UI as perhitungan_modern.php (Controller)
    participant DB as MySQL Database
    participant Theme as smart_accordion.php (Template)

    User->>UI: Pilih Periode Bulan & Klik Hitung Sekarang
    activate UI
    
    UI->>DB: Ambil tagihan berdasarkan periode & sub-kriteria
    activate DB
    DB-->>UI: Kumpulan data tagihan
    deactivate DB
    
    UI->>DB: Ambil kriteria (kode, bobot, tipe)
    activate DB
    DB-->>UI: Kumpulan bobot & tipe aktif
    deactivate DB
    
    UI->>UI: Cari Min & Max kriteria (C1, C2, C3, C4)
    
    loop Per tagihan dalam array
        UI->>UI: Hitung utility value C1 s.d C4 (Benefit/Cost)
        UI->>UI: Hitung skor akhir = Σ (bobot_kriteria * utility)
    end
    
    UI->>UI: Urutkan tagihan (descending menurut skor)
    
    UI->>DB: Cek riwayat perhitungan terdaftar
    activate DB
    DB-->>UI: data riwayat (ada/tidak)
    deactivate DB
    
    alt Riwayat periode & tgl ini sudah ada
        UI->>DB: UPDATE riwayat_perhitungan (hasil_json, rata_skor, dll)
    else Riwayat periode belum ada
        UI->>DB: INSERT INTO riwayat_perhitungan (hasil_json, rata_skor, dll)
    end
    
    UI->>Theme: Renders results (Step 1 s.d 8)
    activate Theme
    Theme-->>UI: HTML Accordion
    deactivate Theme
    
    UI-->>User: Tampilkan Accordion Langkah SMART & Ranking Akhir
    deactivate UI
```

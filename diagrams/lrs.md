# 📊 Logical Record Structure (LRS) - Smart Tagihan

Logical Record Structure (LRS) menggambarkan struktur relasi antar tabel database secara logis, lengkap dengan Primary Key (PK), Foreign Key (FK), tipe data, dan kardinalitas hubungan antar entitas.

```mermaid
erDiagram
    users {
        int id PK
        varchar username
        varchar email
        varchar password
        varchar full_name
        enum role
        enum status
        timestamp created_at
        timestamp updated_at
        timestamp last_login
    }

    kriteria {
        int id PK
        varchar kode UK
        varchar nama_kriteria
        enum tipe
        float bobot
        timestamp created_at
    }

    sub_kriteria {
        int id PK
        varchar kode_kriteria FK
        varchar kode_sub
        varchar nama_sub
        float nilai
        timestamp created_at
    }

    tagihan {
        int id PK
        varchar vendor
        varchar no_tagihan
        int nilai_tagihan
        date tanggal_dokumen
        varchar top
        int top_hari
        date jatuh_tempo
        int id_urgensi FK
        int id_risiko FK
        timestamp created_at
    }

    riwayat_perhitungan {
        int id PK
        varchar bulan_periode
        int total_tagihan
        double total_nilai
        double rata_skor
        int jumlah_data
        longtext hasil_json
        timestamp tanggal_perhitungan
        timestamp updated_at
    }

    audit_log {
        int id PK
        datetime timestamp
        enum action
        int id_tagihan FK
        int user_id FK
        varchar user_name
        varchar ip_address
        longtext details
        timestamp created_at
    }

    %% Relationships and Cardinalities
    kriteria ||--o{ sub_kriteria : "memiliki"
    sub_kriteria ||--o{ tagihan : "sebagai C3 (Urgensi)"
    sub_kriteria ||--o{ tagihan : "sebagai C4 (Risiko)"
    users ||--o{ audit_log : "melakukan aktivitas"
    tagihan ||--o{ audit_log : "mengalami perubahan"
```

### Keterangan Kardinalitas:
* **`kriteria` ke `sub_kriteria` (`1:N`):** Satu kriteria dapat memiliki satu atau banyak sub-kriteria. Satu sub-kriteria hanya merujuk pada satu kriteria tertentu.
* **`sub_kriteria` ke `tagihan` (`1:N`):** Satu data nilai sub-kriteria (Urgensi / Risiko) dapat digunakan oleh banyak data tagihan.
* **`users` ke `audit_log` (`1:N`):** Satu pengguna dapat memicu pencatatan banyak log aktivitas perubahan data.
* **`tagihan` ke `audit_log` (`1:N`):** Satu data tagihan dapat mengalami beberapa kali perubahan (INSERT, UPDATE, DELETE) yang tercatat dalam log audit.

# 🗄️ Entity Relationship Diagram (ERD) - Smart Tagihan

Entity Relationship Diagram (ERD) menggambarkan hubungan logis dan konseptual antar entitas data dalam database `db_smart` yang digunakan oleh sistem pendukung keputusan pembayaran tagihan.

```mermaid
erDiagram
    USERS ||--o{ AUDIT_LOG : "generates"
    KRITERIA ||--o{ SUB_KRITERIA : "defines"
    SUB_KRITERIA ||--o{ TAGIHAN : "determines urgensi"
    SUB_KRITERIA ||--o{ TAGIHAN : "determines risiko"
    TAGIHAN ||--o{ AUDIT_LOG : "logged in"

    USERS {
        int id PK
        string username UNIQUE
        string email UNIQUE
        string password "MD5 hash"
        string full_name
        enum role "admin, user"
        enum status "active, inactive"
        timestamp created_at
        timestamp updated_at
        timestamp last_login
    }

    KRITERIA {
        int id PK
        string kode PK "C1, C2, C3, C4"
        string nama_kriteria
        enum tipe "benefit, cost"
        float bobot
        timestamp created_at
    }

    SUB_KRITERIA {
        int id PK
        string kode_kriteria FK "References KRITERIA.kode"
        string kode_sub
        string nama_sub
        float nilai
        timestamp created_at
    }

    TAGIHAN {
        int id PK
        string vendor
        string no_tagihan
        int nilai_tagihan
        date tanggal_dokumen
        string top "e.g., 1 HARI, 3 HARI, 30 HARI"
        int top_hari
        date jatuh_tempo "Business days calculation"
        int id_urgensi FK "References SUB_KRITERIA.id"
        int id_risiko FK "References SUB_KRITERIA.id"
        timestamp created_at
    }

    AUDIT_LOG {
        int id PK
        datetime timestamp
        enum action "INSERT, UPDATE, DELETE"
        int id_tagihan FK "References TAGIHAN.id"
        int user_id FK "References USERS.id"
        string user_name
        string ip_address
        longtext details "JSON String of changes"
        timestamp created_at
    }

    RIWAYAT_PERHITUNGAN {
        int id PK
        string bulan_periode "YYYY-MM"
        int total_tagihan
        double total_nilai
        double rata_skor
        int jumlah_data
        longtext hasil_json "Full rank results state"
        timestamp tanggal_perhitungan
        timestamp updated_at
    }
```

### Relasi Bisnis Utama:
1. **KRITERIA & SUB_KRITERIA:** Setiap kriteria (seperti C3 Urgensi dan C4 Risiko) dipecah menjadi beberapa parameter penilaian kualitatif di sub-kriteria. Hubungan ini dihubungkan secara dinamis melalui kolom `kode_kriteria` di tabel sub-kriteria yang merujuk pada `kode` di tabel kriteria.
2. **SUB_KRITERIA & TAGIHAN:** Data tagihan yang masuk memiliki relasi langsung ke parameter sub-kriteria untuk kriteria C3 (Urgensi) dan C4 (Risiko) melalui kunci tamu `id_urgensi` dan `id_risiko`. Nilai parameter ini digunakan dalam formula SMART.
3. **USERS, TAGIHAN & AUDIT_LOG:** Setiap kali ada aksi pengubahan data tagihan (tambah manual, impor Excel, edit, atau hapus), sistem mencatat informasi pengguna (`user_id`, `user_name`), identitas tagihan (`id_tagihan`), alamat IP, serta detail lengkap perubahan ke dalam tabel `audit_log`.
4. **RIWAYAT_PERHITUNGAN:** Entitas ini berdiri sendiri (*isolated*) untuk menampung *snapshot* historis hasil akhir perhitungan per periode bulan dalam format JSON. Hal ini berguna untuk menyajikan laporan statis tanpa dipengaruhi oleh perubahan data tagihan aktif di kemudian hari.

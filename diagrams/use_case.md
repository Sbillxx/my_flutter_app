# 👥 Use Case Diagram - Smart Tagihan

Use Case Diagram menggambarkan interaksi antara pengguna sistem (Aktor) dan kasus penggunaan (Fitur/Fungsi) yang disediakan di dalam sistem pendukung keputusan pembayaran tagihan.

```mermaid
graph LR
    %% Actors Definition
    admin[👤 Administrator]
    user[👤 General User]

    subgraph SystemBoundary [Smart Tagihan System]
        %% Use Cases
        uc_login(["Sesi Login & Proteksi Idle Timeout"])
        uc_dashboard(["Melihat Visualisasi Dashboard Prioritas"])
        uc_tagihan(["Mengelola Data Tagihan<br>CRUD & Impor Excel"])
        uc_kriteria(["Mengatur Bobot & Tipe Kriteria<br>Benefit/Cost"])
        uc_sub_kriteria(["Mengatur Parameter Nilai Sub-Kriteria"])
        uc_hitung(["Menjalankan Perhitungan SMART<br>Interactive Accordion Steps"])
        uc_riwayat(["Melihat & Mencetak Riwayat Laporan"])
        uc_audit(["Audit Log Perubahan Data"])
    end

    %% Make the subgraph background transparent
    style SystemBoundary fill:transparent,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5

    %% Relations for Admin (Full Access)
    admin --> uc_login
    admin --> uc_dashboard
    admin --> uc_tagihan
    admin --> uc_kriteria
    admin --> uc_sub_kriteria
    admin --> uc_hitung
    admin --> uc_riwayat
    admin --> uc_audit

    %% Relations for General User (Read Only & Calculate)
    user --> uc_login
    user --> uc_dashboard
    user --> uc_riwayat
    user --> uc_hitung
```

### Deskripsi Aktor & Hak Akses (Role Mapping):

Sistem membagi hak akses ke dalam 2 peran utama:

1. **Administrator (admin):**
   * Memiliki akses penuh terhadap seluruh modul sistem.
   * Bertanggung jawab melakukan pengelolaan kriteria (`C1` s.d `C4`), penentuan bobot pentingnya masing-masing kriteria, serta konfigurasi parameter nilai sub-kriteria.
   * Mengimpor data tagihan vendor dari Excel, mengedit, atau menghapus tagihan secara massal.
   * Meninjau jejak audit log aktivitas transaksi pada sistem.
2. **General User (user):**
   * Memiliki hak akses terbatas yang berfokus pada pemantauan hasil keputusan dan laporan.
   * Dapat melihat grafik distribusi prioritas pembayaran di halaman Dashboard.
   * Menjalankan simulasi perhitungan SMART untuk melihat urutan ranking tagihan pada bulan terpilih.
   * Mengunduh atau mencetak laporan riwayat perhitungan bulanan.

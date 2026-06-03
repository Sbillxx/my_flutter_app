# 🧱 Class Diagram - Smart Tagihan

Class Diagram di bawah memvisualisasikan struktur sistem dari perspektif berorientasi objek logis. Meskipun proyek dibangun di atas bahasa PHP prosedural terstruktur, representasi kelas logis ini memetakan bagaimana modul-modul sistem berinteraksi, memproses data, dan mengakses tabel database.

```mermaid
classDiagram
    %% Class definitions
    class DatabaseConnection {
        +mysqli conn
        +connect()
        +close()
    }

    class SessionManagerLogis {
        +int user_id
        +string user_name
        +string role
        +startSession()
        +checkSessionTimeout()
        +restoreRememberMe()
    }

    class AuditLogger {
        +logAudit(conn, action, id_tagihan, details)
        +createInsertDetails(vendor, no_tagihan, nilai, tanggal, top, top_hari)
        +createUpdateDetails(old_data, new_data)
        +createDeleteDetails(data)
    }

    class TagihanController {
        +int id
        +string vendor
        +string no_tagihan
        +int nilai_tagihan
        +date tanggal_dokumen
        +string top
        +int top_hari
        +date jatuh_tempo
        +int id_urgensi
        +int id_risiko
        +hitungHariKerja(tanggal_awal, jumlah_hari)
        +simpanTagihanManual()
        +importExcel()
        +hapusTagihan()
    }

    class KriteriaController {
        +int id
        +string kode
        +string nama_kriteria
        +string tipe
        +float bobot
        +tambahKriteria()
        +updateKriteria()
        +hapusKriteria()
    }

    class SubKriteriaController {
        +int id
        +string kode_kriteria
        +string kode_sub
        +string nama_sub
        +float nilai
        +tambahSubKriteria()
        +updateSubKriteria()
        +hapusSubKriteria()
    }

    class SMARTCalculator {
        +string selected_bulan
        +array dataArr
        +array hasil
        +float safe_div(a, b)
        +hitungMinMax()
        +hitungUtilityBenefit(value, min, max)
        +hitungUtilityCost(value, min, max)
        +kalkulasiSkorSMART()
        +simpanRiwayatKeDB()
    }

    class DashboardController {
        +int totalTagihan
        +double totalNilai
        +int totalKriteria
        +double avg_skor
        +getStatistikDasar()
        +getDistribusiStatus()
        +getTop3Tagihan()
    }

    %% Class relationships
    TagihanController ..> DatabaseConnection : "uses"
    KriteriaController ..> DatabaseConnection : "uses"
    SubKriteriaController ..> DatabaseConnection : "uses"
    SMARTCalculator ..> DatabaseConnection : "uses"
    DashboardController ..> DatabaseConnection : "uses"

    TagihanController ..> AuditLogger : "calls"
    TagihanController ..> SessionManagerLogis : "checks user session"
    SMARTCalculator ..> SessionManagerLogis : "saves output to session"
    DashboardController ..> SessionManagerLogis : "reads calculation state"

    KriteriaController "1" *-- "many" SubKriteriaController : "has"
    SubKriteriaController "many" <-- "1" TagihanController : "references via ID"
```

### Keterangan Komponen Struktur:
1. **`DatabaseConnection` (`config/koneksi.php`):** Menyediakan koneksi database MySQL (`$conn`) ke seluruh modul pengontrol transaksi data.
2. **`SessionManagerLogis` (`config/SessionManager.php` & `check_session.php`):** Mengatur kredensial masuk pengguna terautentikasi (`user_id`, `role`), durasi sesi idle, dan kunci sesi masukan.
3. **`AuditLogger` (`config/audit_log.php`):** Memproses serialisasi objek data ke format JSON untuk mencatat jejak audit penambahan/pengubahan data tagihan.
4. **`TagihanController` (`tagihan.php`, `proses.php`, dll):** Mengatur input data manual, unggahan file menggunakan PhpSpreadsheet, kalkulasi tanggal jatuh tempo, dan penghapusan data per bulan.
5. **`SMARTCalculator` (`perhitungan_modern.php`):** Jantung proses pemrosesan keputusan. Mengatur formula perhitungan Min/Max kriteria, kalkulasi utility benefit & cost, pembobotan prioritas, penyusunan ranking, serta pencatatan arsip ke riwayat perhitungan.
6. **`DashboardController` (`dashboard.php`):** Mengagregasikan data kalkulasi prioritas dari sesi aktif untuk divisualisasikan dalam status ringkasan prioritas tinggi, sedang, rendah dan grafik.

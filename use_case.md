# 👥 Use Case Diagram - Executive Command Dashboard

Use Case Diagram ini menggambarkan interaksi antara **Division Lead (Kepala / Executive)** dan **Laravel Backend/System Scheduler** sebagai aktor dengan sistem Executive Command Dashboard.

```mermaid
flowchart TD
    %% Actors
    Executive["👤 Division Lead\n(Kepala / Executive)"]
    System["🤖 Laravel Backend\n& Scheduler"]

    %% Use Cases Boundary
    subgraph DashboardSystem ["Executive Command Dashboard System"]
        uc_login(["Sesi Login & Keamanan Akun"])
        uc_view_dashboard(["Melihat KPI Dasbor & Produktivitas"])
        uc_manage_staff(["Mengelola Direktori Staf\n(Lihat, Cari, Filter)"])
        uc_add_staff(["Menambahkan Staf Baru"])
        uc_edit_staff(["Mengubah Profil Staf"])
        uc_delete_staff(["Menghapus Staf"])
        uc_assign_task(["Menugaskan Tugas Baru"])
        uc_submit_feedback(["Mengirim Umpan Balik & Rating"])
        uc_recalc_workload(["Menghitung Otomatis Beban Kerja"])
        uc_manage_projects(["Mengelola Proyek\n(CRUD Proyek)"])
        uc_view_project_detail(["Melihat Detail Proyek & Tugas/Bug"])
        uc_view_reports(["Melihat & Mengunduh Laporan"])
        uc_receive_notifications(["Menerima Notifikasi & Peringatan"])
    end

    %% Relations for Executive
    Executive ---> uc_login
    Executive ---> uc_view_dashboard
    Executive ---> uc_manage_staff
    Executive ---> uc_add_staff
    Executive ---> uc_edit_staff
    Executive ---> uc_delete_staff
    Executive ---> uc_assign_task
    Executive ---> uc_submit_feedback
    Executive ---> uc_manage_projects
    Executive ---> uc_view_project_detail
    Executive ---> uc_view_reports
    Executive ---> uc_receive_notifications

    %% Relations for System
    System ---> uc_recalc_workload
    System ---> uc_receive_notifications

    %% Include Relations
    uc_add_staff -.-> |"<<include>>"| uc_recalc_workload
    uc_assign_task -.-> |"<<include>>"| uc_recalc_workload
    uc_submit_feedback -.-> |"<<include>>"| uc_recalc_workload
    uc_recalc_workload -.-> |"<<include>>"| uc_receive_notifications

    %% Styles
    style DashboardSystem fill:#111827,stroke:#3B82F6,stroke-width:2px,color:#fff
    style Executive fill:#1E293B,stroke:#3B82F6,stroke-width:1px,color:#fff
    style System fill:#1E293B,stroke:#10B981,stroke-width:1px,color:#fff
```

### Deskripsi Aktor & Hubungan Sistem:

1. **Division Lead (Kepala / Executive) [Aktor Utama]:**
   * Mengawasi seluruh kinerja divisi melalui dasbor metrik visual (weekly productivity, top performers).
   * Melakukan administrasi kepegawaian (menambah, memperbarui, atau menghapus data staf).
   * Memantau beban kerja masing-masing staf dan mendelegasikan tugas personal baru jika beban kerja staf masih aman.
   * Memberikan evaluasi berupa ulasan kualitatif dan rating numerik untuk menghitung keandalan (*reliability*) staf.
   * Mengelola siklus proyek (tambah proyek baru, pembaruan, hapus, dan memantau tugas/bug).
   * Meninjau dan mengunduh laporan penting divisi (LKIP, PKPT, RKT).

2. **Laravel System / Scheduler [Aktor Pendukung]:**
   * Menghitung ulang secara otomatis persentase beban kerja staf (*workload percentage*) dan tingkat risiko staf (`NORMAL`, `HIGH`, `AT RISK`) berdasarkan jumlah tugas aktif.
   * Menghitung output mingguan staf secara dinamis berdasarkan tugas personal dan proyek yang diselesaikan dalam 7 hari terakhir.
   * Membuat log peringatan sistem (`system_notifications`) jika kapasitas staf melebihi batas (misalnya staf bertatus `AT RISK`).
   * Memicu pengiriman *local push notification* di aplikasi mobile Flutter.

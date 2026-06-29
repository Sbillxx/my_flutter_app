# 🏃‍♂️ Activity Diagram 1 - Penugasan Staf & Perhitungan Beban Kerja

Activity Diagram ini menggambarkan alur kerja (*workflow*) ketika **Executive (Division Lead)** menugaskan tugas baru ke staf, dilanjutkan dengan proses perhitungan otomatis beban kerja oleh **Laravel Backend** secara real-time.

```mermaid
flowchart TD
    %% Swimlane - FLUTTER MOBILE (FRONTEND)
    subgraph FlutterApp ["Front-End: Flutter Mobile App"]
        start([Mulai]) --> select_staff["Pilih Staf di Direktori Staf"]
        select_staff --> view_details["Lihat Profil & Beban Kerja Aktual"]
        view_details --> click_assign["Ketuk Assign Task"]
        click_assign --> fill_form["Isi Form: Judul, Deskripsi, Tenggat Waktu"]
        fill_form --> submit_task["Kirim Data Form"]
        
        %% Response Handling
        offline_mock["Simulasi Offline Fallback"] --> show_sim_dialog["Tampilkan Dialog Sukses Offline"]
        show_sim_dialog --> end_sim([Selesai - Simulasi])
        
        parse_res["Parse Respons Data Tugas & Beban Kerja Baru"] --> update_ui["Perbarui UI Profil Staf & Indikator Risiko"]
        update_ui --> check_notif_service["Picu Local Notification Service"]
        check_notif_service --> show_android_tray["Tampilkan Notifikasi Sistem di Android Notification Tray"]
        show_android_tray --> end_prod([Selesai - Realtime])
        
        show_err["Tampilkan Pesan Error di Form"] --> fill_form
    end

    %% Swimlane - API CONNECTION
    subgraph ApiConnection ["Connection: ApiService"]
        submit_task --> check_network{"Apakah Server Terhubung?"}
        check_network -->|Ya| post_request["Kirim HTTP POST ke /api/staff/:id/task"]
        check_network -->|Tidak| offline_fallback["Tangkap Eksepsi & Ambil Fallback Mock"]
    end

    %% Swimlane - LARAVEL BACKEND & DB
    subgraph LaravelBackend ["Back-End: Laravel & Database"]
        post_request --> validate_req{"Validasi Input?"}
        
        validate_req -->|Gagal| return_422["Kirim Respon HTTP 422"]
        validate_req -->|Sukses| save_task["Simpan ke Tabel tasks"]
        
        save_task --> log_notification["Simpan Log Notifikasi ke Tabel system_notifications"]
        log_notification --> trigger_recalc["Jalankan Fungsi recalculateWorkload"]
        
        trigger_recalc --> query_active["Hitung Total Tugas Aktif: Personal + Proyek"]
        query_active --> check_threshold{"Evaluasi Batas Kapasitas"}
        
        check_threshold -->|Tugas ge 6| status_risk["Status: AT RISK"]
        check_threshold -->|Tugas 4-5| status_high["Status: HIGH"]
        check_threshold -->|Tugas lt 4| status_normal["Status: NORMAL"]
        
        status_risk --> update_anggota["Update Kolom workload_percentage & status di Tabel anggotas"]
        status_high --> update_anggota
        status_normal --> update_anggota
        
        update_anggota --> return_200["Kirim Respon HTTP 200 OK + JSON Data"]
    end

    %% Handoff Connections
    offline_fallback --> offline_mock
    return_422 --> show_err
    return_200 --> parse_res

    %% Styles
    style start fill:#1E293B,stroke:#3B82F6,stroke-width:1px,color:#fff
    style end_sim fill:#1E293B,stroke:#EF4444,stroke-width:1px,color:#fff
    style end_prod fill:#1E293B,stroke:#10B981,stroke-width:1px,color:#fff
    style FlutterApp fill:#0F172A,stroke:#3B82F6,stroke-width:2px,color:#fff
    style ApiConnection fill:#111827,stroke:#9CA3AF,stroke-width:2px,color:#fff
    style LaravelBackend fill:#090D16,stroke:#10B981,stroke-width:2px,color:#fff
```

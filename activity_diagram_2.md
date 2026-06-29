# 🏃‍♂️ Activity Diagram 2 - Evaluasi & Reliabilitas Kinerja Staf

Activity Diagram ini menggambarkan alur kerja (*workflow*) ketika **Executive (Division Lead)** mengirimkan ulasan umpan balik dan rating evaluasi untuk staf, dilanjutkan dengan proses perhitungan rata-rata tingkat keandalan (*reliability score*) secara dinamis oleh **Laravel Backend**.

```mermaid
flowchart TD
    %% Swimlane - FLUTTER MOBILE (FRONTEND)
    subgraph FlutterApp ["Front-End: Flutter Mobile App"]
        start([Mulai]) --> select_staff["Pilih Staf di Direktori Staf"]
        select_staff --> view_details["Lihat Profil & Keandalan Aktual"]
        view_details --> click_feedback["Ketuk Beri Umpan Balik"]
        click_feedback --> fill_form["Isi Form: Catatan & Rating 1-5 Bintang"]
        fill_form --> submit_feedback["Kirim Form Evaluasi"]
        
        %% Response Handling
        offline_mock["Simulasi Offline Fallback"] --> show_sim_dialog["Tampilkan Dialog Sukses Offline"]
        show_sim_dialog --> end_sim([Selesai - Simulasi])
        
        parse_res["Parse Respons Data Evaluasi Baru"] --> update_ui["Perbarui Skor Reliabilitas & List Riwayat Evaluasi Staf"]
        update_ui --> check_notif_service["Picu Local Notification Service"]
        check_notif_service --> show_android_tray["Tampilkan Banner Notifikasi Evaluasi di Tray"]
        show_android_tray --> end_prod([Selesai - Realtime])
        
        show_err["Tampilkan Pesan Validasi di Form"] --> fill_form
    end

    %% Swimlane - API CONNECTION
    subgraph ApiConnection ["Connection: ApiService"]
        submit_feedback --> check_network{"Apakah Server Terhubung?"}
        check_network -->|Ya| post_request["Kirim HTTP POST ke /api/staff/:id/feedback"]
        check_network -->|Tidak| offline_fallback["Tangkap Eksepsi & Ambil Fallback Mock"]
    end

    %% Swimlane - LARAVEL BACKEND & DB
    subgraph LaravelBackend ["Back-End: Laravel & Database"]
        post_request --> validate_req{"Validasi: Catatan diisi & Rating 1 s.d 5?"}
        
        validate_req -->|Gagal| return_422["Kirim Respon HTTP 422"]
        validate_req -->|Sukses| save_eval["Simpan ke Tabel evaluations"]
        
        save_eval --> log_notification["Simpan Log Evaluasi ke Tabel system_notifications"]
        log_notification --> get_avg_rating["Hitung Rata-rata Rating dari Seluruh Evaluasi Staf"]
        
        get_avg_rating --> calculate_reliability["Hitung Persentase Keandalan: min(100.0, (avg / 5.0) * 100)"]
        calculate_reliability --> update_anggota["Simpan Skor Keandalan Baru ke Tabel anggotas"]
        
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

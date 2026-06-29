# 🏃‍♂️ Activity Diagram 3 - Pembuatan Proyek Baru & Alokasi Tim

Activity Diagram ini menggambarkan alur kerja (*workflow*) ketika **Executive (Division Lead)** menambahkan proyek baru ke dalam dasbor, memilih divisi penanggung jawab, serta mengalokasikan anggota staf ke dalam proyek tersebut.

```mermaid
flowchart TD
    %% Swimlane - FLUTTER MOBILE (FRONTEND)
    subgraph FlutterApp ["Front-End: Flutter Mobile App"]
        start([Mulai]) --> open_projects["Buka Tab Proyek"]
        open_projects --> click_add["Ketuk Tambah Proyek"]
        click_add --> fill_form["Isi Form: Nama, Deskripsi, Tenggat, Divisi, & Pilih Staf"]
        fill_form --> submit_project["Kirim Form Proyek Baru"]
        
        %% Response Handling
        offline_mock["Simulasi Offline Fallback"] --> show_sim_dialog["Tampilkan Dialog Sukses Offline"]
        show_sim_dialog --> end_sim([Selesai - Simulasi])
        
        parse_res["Parse Respons Data Proyek Baru"] --> update_ui["Perbarui Daftar Proyek & Rekalkulasi KPI Staf Aktif"]
        update_ui --> check_notif_service["Picu Local Notification Service"]
        check_notif_service --> show_android_tray["Tampilkan Banner Notifikasi Proyek di Tray"]
        show_android_tray --> end_prod([Selesai - Realtime])
        
        show_err["Tampilkan Pesan Validasi di Form"] --> fill_form
    end

    %% Swimlane - API CONNECTION
    subgraph ApiConnection ["Connection: ApiService"]
        submit_project --> check_network{"Apakah Server Terhubung?"}
        check_network -->|Ya| post_request["Kirim HTTP POST ke /api/projects"]
        check_network -->|Tidak| offline_fallback["Tangkap Eksepsi & Ambil Fallback Mock"]
    end

    %% Swimlane - LARAVEL BACKEND & DB
    subgraph LaravelBackend ["Back-End: Laravel & Database"]
        post_request --> validate_req{"Validasi: Nama & Target Date diisi?"}
        
        validate_req -->|Gagal| return_422["Kirim Respon HTTP 422"]
        validate_req -->|Sukses| save_project["Simpan ke Tabel projects (Simpan assigned_staff sebagai JSON Array)"]
        
        save_project --> log_notification["Simpan Log Proyek ke Tabel system_notifications"]
        log_notification --> return_201["Kirim Respon HTTP 210/201 Created + JSON Data"]
    end

    %% Handoff Connections
    offline_fallback --> offline_mock
    return_422 --> show_err
    return_201 --> parse_res

    %% Styles
    style start fill:#1E293B,stroke:#3B82F6,stroke-width:1px,color:#fff
    style end_sim fill:#1E293B,stroke:#EF4444,stroke-width:1px,color:#fff
    style end_prod fill:#1E293B,stroke:#10B981,stroke-width:1px,color:#fff
    style FlutterApp fill:#0F172A,stroke:#3B82F6,stroke-width:2px,color:#fff
    style ApiConnection fill:#111827,stroke:#9CA3AF,stroke-width:2px,color:#fff
    style LaravelBackend fill:#090D16,stroke:#10B981,stroke-width:2px,color:#fff
```

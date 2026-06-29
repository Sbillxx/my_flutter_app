# ⏱️ Sequence Diagram 1 - Sinkronisasi Dasbor & Fallback Offline

Sequence Diagram ini menggambarkan interaksi pesan antara aplikasi **Flutter**, **Laravel API**, **Database**, dan **Android OS** saat memuat dasbor eksekutif dengan mekanisme pertahanan kegagalan jaringan (*network fallback*).

```mermaid
sequenceDiagram
    autonumber
    actor Executive as 👤 Executive / Division Lead
    participant OverviewTab as 📱 OverviewTab (Flutter UI)
    participant ApiService as ⚙️ ApiService (Flutter)
    participant LaravelAPI as ☁️ Laravel API (Server)
    participant Database as 🗄️ Database (Laravel DB)
    participant NotificationService as 🔔 NotificationService
    participant AndroidOS as 🤖 Android OS (System Tray)

    Executive->>OverviewTab: Buka Aplikasi / Picu 'onRefresh'
    activate OverviewTab
    OverviewTab->>OverviewTab: Set State: _isLoading = true
    
    %% Fetch Dashboard Data
    OverviewTab->>ApiService: getDashboard()
    activate ApiService
    ApiService->>LaravelAPI: HTTP GET /api/dashboard (timeout 3s)
    activate LaravelAPI
    
    alt Koneksi Sukses (HTTP 200)
        LaravelAPI->>Database: Query KPI & Top Performers
        Database-->>LaravelAPI: Return Data Hasil Query
        LaravelAPI-->>ApiService: Return JSON {status: 'success', data: {...}}
    else Koneksi Gagal / Timeout
        Note over ApiService, LaravelAPI: Jaringan Terputus / Server Mati
        LaravelAPI--xApiService: Connection Exception
        deactivate LaravelAPI
        ApiService->>ApiService: Tangkap error & Ambil Fallback Mock Data Lokal
    end
    
    ApiService-->>OverviewTab: Return Map Data Dashboard
    deactivate ApiService
    
    %% Fetch Notification Data
    OverviewTab->>ApiService: getNotifications()
    activate ApiService
    ApiService->>LaravelAPI: HTTP GET /api/notifications (timeout 3s)
    activate LaravelAPI
    
    alt Koneksi Sukses (HTTP 200)
        LaravelAPI->>Database: Query Notifikasi Terbaru
        Database-->>LaravelAPI: Return Notifikasi List
        LaravelAPI-->>ApiService: Return JSON {status: 'success', data: {...}}
    else Koneksi Gagal / Timeout
        LaravelAPI--xApiService: Connection Exception
        deactivate LaravelAPI
        ApiService->>ApiService: Ambil Fallback Mock Data Notifikasi Lokal
    end
    
    ApiService-->>OverviewTab: Return Map Data Notifikasi
    deactivate ApiService
    
    %% Processing UI Update & Real-Time OS Push
    OverviewTab->>OverviewTab: Set State: _isLoading = false & update data
    OverviewTab->>OverviewTab: Filter Notifikasi: isRead == false & ID baru?
    
    loop Untuk Setiap Notifikasi Belum Dibaca
        OverviewTab->>NotificationService: showNotification(id, title, body)
        activate NotificationService
        NotificationService->>AndroidOS: Buat Notifikasi Lokal Sistem (Channel ID)
        activate AndroidOS
        AndroidOS-->>NotificationService: Tampilkan banner notifikasi di layar
        deactivate AndroidOS
        NotificationService->>NotificationService: Catat ID telah ditampilkan (markAsShown)
        deactivate NotificationService
    end
    
    OverviewTab-->>Executive: Render Dasbor & Notifikasi Selesai
    deactivate OverviewTab
```

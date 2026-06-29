# ⏱️ Sequence Diagram 2 - Pendelegasian Tugas Baru & Notifikasi Android

Sequence Diagram ini menggambarkan sekuens pesan interaktif ketika **Executive (Division Lead)** mendelegasikan tugas personal baru ke staf dari form antarmuka detail staf Flutter, dilanjutkan dengan pemrosesan di database Laravel, dan pemicu banner notifikasi di Android OS.

```mermaid
sequenceDiagram
    autonumber
    actor Executive as 👤 Executive / Division Lead
    participant StaffDetailScreen as 📱 StaffDetailScreen (Flutter UI)
    participant ApiService as ⚙️ ApiService (Flutter)
    participant LaravelAPI as ☁️ Laravel API (Server)
    participant Database as 🗄️ Database (Laravel DB)
    participant NotificationService as 🔔 NotificationService
    participant AndroidOS as 🤖 Android OS (System Tray)

    Executive->>StaffDetailScreen: Masukkan form tugas baru & ketuk Kirim
    activate StaffDetailScreen
    StaffDetailScreen->>ApiService: assignTask(staffId, title, desc, dueDate)
    activate ApiService
    
    ApiService->>LaravelAPI: HTTP POST /api/staff/{id}/task (JSON body)
    activate LaravelAPI
    
    LaravelAPI->>Database: Simpan tugas baru ke tabel tasks
    LaravelAPI->>Database: Simpan audit notifikasi ke tabel system_notifications
    LaravelAPI->>Database: Query update beban kerja & status staf
    Database-->>LaravelAPI: Return data berhasil disimpan & kalkulasi selesai
    
    LaravelAPI-->>ApiService: Return JSON {status: success, data: {task_id, status}}
    deactivate LaravelAPI
    
    ApiService-->>StaffDetailScreen: Return Map data tugas baru
    deactivate ApiService
    
    StaffDetailScreen->>StaffDetailScreen: Render ulang UI (update status & list tugas)
    StaffDetailScreen-->>Executive: Tampilkan popup sukses & daftar tugas diperbarui
    
    %% Triggers background local notification on next overview refresh or immediate action
    StaffDetailScreen->>NotificationService: showNotification(id, "Tugas Baru", "Tugas baru ditugaskan ke staf")
    activate NotificationService
    NotificationService->>AndroidOS: Buat Banner Notifikasi Sistem
    activate AndroidOS
    AndroidOS-->>NotificationService: Tampilkan notifikasi di tray
    deactivate AndroidOS
    deactivate NotificationService
    deactivate StaffDetailScreen
```

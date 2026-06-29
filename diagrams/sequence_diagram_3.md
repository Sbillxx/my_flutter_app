# ⏱️ Sequence Diagram 3 - Submit Umpan Balik & Update Skor Kinerja Staf

Sequence Diagram ini menggambarkan sekuens pesan interaktif ketika **Executive (Division Lead)** mengirimkan ulasan evaluasi kualitatif dan rating numerik untuk staf, dilanjutkan dengan pemrosesan di database Laravel untuk pembaruan skor reliabilitas kepegawaian secara real-time.

```mermaid
sequenceDiagram
    autonumber
    actor Executive as 👤 Executive / Division Lead
    participant StaffDetailScreen as 📱 StaffDetailScreen (Flutter UI)
    participant ApiService as ⚙️ ApiService (Flutter)
    participant LaravelAPI as ☁️ Laravel API (Server)
    participant Database as 🗄️ Database (Laravel DB)

    Executive->>StaffDetailScreen: Isi catatan evaluasi & pilih rating 1-5 bintang
    activate StaffDetailScreen
    StaffDetailScreen->>ApiService: submitFeedback(staffId, note, rating)
    activate ApiService
    
    ApiService->>LaravelAPI: HTTP POST /api/staff/{id}/feedback (JSON body)
    activate LaravelAPI
    
    LaravelAPI->>Database: Simpan evaluasi baru ke tabel evaluations
    LaravelAPI->>Database: Simpan audit ke tabel system_notifications
    LaravelAPI->>Database: Hitung rata-rata rating baru & persentase keandalan
    LaravelAPI->>Database: Update kolom reliability di tabel anggotas
    Database-->>LaravelAPI: Return data berhasil disimpan & diperbarui
    
    LaravelAPI-->>ApiService: Return JSON {status: success, data: {rating, reliability}}
    deactivate LaravelAPI
    
    ApiService-->>StaffDetailScreen: Return Map data evaluasi
    deactivate ApiService
    
    StaffDetailScreen->>StaffDetailScreen: Render ulang UI (update reliability & rating list)
    StaffDetailScreen-->>Executive: Tampilkan dialog ulasan berhasil dikirim & skor reliabilitas terupdate
    deactivate StaffDetailScreen
```

# 🗄️ Entity Relationship Diagram (ERD) - Executive Command Dashboard

Entity Relationship Diagram (ERD) ini mendokumentasikan skema dan relasi antar tabel pada database **Laravel** yang digunakan oleh Executive Command Dashboard.

```mermaid
erDiagram
    users {
        int id PK
        string name
        string email
        string password
        int team_id FK
        string avatar_url
    }
    teams {
        int id PK
        string name
    }
    divisis {
        int id PK
        string nama
        string kode
    }
    anggotas {
        int id PK
        int user_id FK
        int divisi_id FK
        string nama
        string jabatan
        string foto
        string status
        int workload_percentage
        int total_tasks
        int active_tasks_count
        float reliability
        int weekly_output
    }
    tasks {
        int id PK
        int anggota_id FK
        string title
        string description
        string due_date
        string status
    }
    evaluations {
        int id PK
        int anggota_id FK
        string note
        string date
        float rating
    }
    projects {
        int id PK
        string name
        string description
        int progress
        string workload
        int divisi_id FK
        string assigned_staff
        string target_date
        int user_id FK
        int team_id FK
    }
    project_user {
        int project_id FK
        int user_id FK
    }
    project_tasks {
        int id PK
        int project_id FK
        string title
        string description
        string status
        string priority
        string due_date
        int assigned_to FK
        string image_path
    }
    project_bugs {
        int id PK
        int project_id FK
        string title
        string status
        string severity
    }
    project_reports {
        int id PK
        int project_id FK
        string file_name
        string file_path
        string file_size
    }
    system_notifications {
        int id PK
        string title
        string description
        string time_ago
        string type
        string color
        boolean is_read
    }

    teams ||--o{ users : "has members"
    teams ||--o{ projects : "manages"
    users ||--o{ projects : "creates"
    divisis ||--o{ anggotas : "contains"
    divisis ||--o{ projects : "associates"
    users ||--o| anggotas : "links"
    anggotas ||--o{ tasks : "gets"
    anggotas ||--o{ evaluations : "receives"
    projects ||--o{ project_tasks : "contains"
    projects ||--o{ project_bugs : "tracks"
    projects ||--o{ project_reports : "contains"
    users ||--o{ project_tasks : "assigned to"
    projects ||--o{ project_user : "assigned team"
    users ||--o{ project_user : "participates"
```

### Deskripsi Tabel & Relasi:

1. **divisis & anggotas:**
   * Setiap staf (`anggotas`) terdaftar dalam satu divisi (`divisis`) melalui kunci asing `divisi_id` (relasi 1-ke-banyak).

2. **anggotas, tasks, & evaluations:**
   * Data `anggotas` memiliki banyak tugas personal (`tasks`) yang didelegasikan oleh pimpinan.
   * Data `anggotas` memiliki catatan evaluasi (`evaluations`) untuk menghitung performa (keandalan / `reliability`) secara rata-rata dinamis.

3. **users & anggotas:**
   * Pimpinan (`users` berhak login ke dasbor) terhubung secara opsional (1-ke-1) ke data staf (`anggotas`) melalui `user_id` untuk menghubungkan pekerjaan proyek dan personal mereka.

4. **projects & project_tasks/bugs/reports:**
   * Setiap proyek (`projects`) dinaungi oleh satu divisi (`divisi_id`) dan tim (`team_id`).
   * Proyek memiliki relasi 1-ke-banyak ke `project_tasks` (detail tugas tim), `project_bugs` (kutu/isu sistem), dan `project_reports` (laporan file unggahan eksternal).

5. **system_notifications:**
   * Berdiri sendiri sebagai audit trail aktivitas sistem, menyimpan peristiwa seperti keberhasilan pengerjaan tugas, peringatan kapasitas beban kerja staf, dan progres proyek.

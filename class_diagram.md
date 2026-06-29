# 🏛️ Class Diagram - Executive Command Dashboard

Class Diagram ini memetakan kelas-kelas utama pada aplikasi mobile **Flutter** (Frontend) serta model data dan kontroler pada **Laravel** (Backend) yang terhubung via REST API.

```mermaid
classDiagram
    %% Flutter UI/Screens
    class MainNavigationScreen {
        -int _currentIndex
        -List~Widget~ _tabs
        +build(BuildContext context) Widget
    }

    class OverviewTab {
        -bool _isLoading
        -String _profileName
        -String _profileAvatarUrl
        -Map _kpis
        -List _topPerformers
        -_loadDashboardData() Future
        -_getImageProvider(String url) ImageProvider
    }

    class StaffDirectoryTab {
        -String _searchQuery
        -String _selectedDivision
        -String _selectedWorkload
        -List _staffList
        -_fetchStaffData() Future
        -_showAddStaffDialog() void
    }

    class StaffDetailScreen {
        +int staffId
        -Map _staffDetails
        -bool _isLoading
        -_fetchDetails() Future
        -_showAssignTaskSheet() void
        -_showFeedbackSheet() void
        -_deleteStaff() Future
    }

    class ProjectsTab {
        -String _searchQuery
        -List _projectsList
        -_fetchProjects() Future
        -_showAddEditProjectDialog(Map? project) void
    }

    class ProjectDetailScreen {
        +int projectId
        -Map _projectDetails
        -bool _isLoading
        -_fetchProjectDetails() Future
    }

    class ReportsTab {
        -Map _metrics
        -List _reportsList
        -_fetchReportsData() Future
        -_simulateDownload(String reportName) void
    }

    class ProfileScreen {
        -TextEditingController _nameController
        -TextEditingController _emailController
        -String _avatarUrl
        -_updateProfile() Future
        -_pickAndUploadAvatar() Future
    }

    class AccountSecurityScreen {
        -TextEditingController _currentPasswordController
        -TextEditingController _newPasswordController
        -_changePassword() Future
    }

    class NotificationSheet {
        -List _notifications
        -_fetchNotifications() Future
        -_markAllAsRead() Future
    }

    %% Flutter Services
    class ApiService {
        <<service>>
        +String baseUrl$
        +_get(String path, Map fallback) Future$
        +_post(String path, Map body, Map fallback) Future$
        +getDashboard() Future$
        +getStaff(String? search, String? workload, String? division) Future$
        +getStaffDetail(int id) Future$
        +assignTask(int staffId, String title, String desc, String due) Future$
        +submitFeedback(int staffId, String note, double rating) Future$
        +getProjects(String? search) Future$
        +addProject(String name, String desc, String target, String workload, String div, List staff) Future$
        +getProjectDetails(int id) Future$
        +getNotifications() Future$
        +getProfile() Future$
    }

    class NotificationService {
        <<service>>
        -FlutterLocalNotificationsPlugin _plugin$
        +initialize() Future$
        +showNotification(int id, String title, String body) Future$
        +markAsShown(int id) void$
    }

    %% Laravel Controllers
    class StaffController {
        <<controller>>
        +index(Request request) JsonResponse
        +show(int id) JsonResponse
        +store(Request request) JsonResponse
        +update(Request request, int id) JsonResponse
        +destroy(int id) JsonResponse
        +assignTask(Request request, int id) JsonResponse
        +submitFeedback(Request request, int id) JsonResponse
    }

    class ProjectController {
        <<controller>>
        +index(Request request) JsonResponse
        +show(int id) JsonResponse
        +store(Request request) JsonResponse
        +update(Request request, int id) JsonResponse
        +destroy(int id) JsonResponse
    }

    %% Laravel Models
    class User {
        <<model>>
        +int id
        +String name
        +String email
        +String password
        +int team_id
        +projects() HasMany
    }

    class Divisi {
        <<model>>
        +int id
        +String nama
        +String kode
        +anggotas() HasMany
        +projects() HasMany
    }

    class Anggota {
        <<model>>
        +int id
        +int user_id
        +int divisi_id
        +String nama
        +String jabatan
        +String status
        +int workload_percentage
        +int active_tasks_count
        +double reliability
        +int weekly_output
        +divisi() BelongsTo
        +tasks() HasMany
        +evaluations() HasMany
        +recalculateWorkload() void
    }

    class Task {
        <<model>>
        +int id
        +int anggota_id
        +String title
        +String description
        +String due_date
        +String status
        +anggota() BelongsTo
    }

    class Evaluation {
        <<model>>
        +int id
        +int anggota_id
        +String note
        +String date
        +double rating
        +anggota() BelongsTo
    }

    class Project {
        <<model>>
        +int id
        +String name
        +String description
        +int progress
        +String workload
        +int divisi_id
        +String assigned_staff
        +divisi() BelongsTo
        +tasks() HasMany
        +bugs() HasMany
        +reports() HasMany
    }

    class ProjectTask {
        <<model>>
        +int id
        +int project_id
        +String title
        +String status
        +int assigned_to
        +project() BelongsTo
    }

    class ProjectBug {
        <<model>>
        +int id
        +int project_id
        +String title
        +String status
        +project() BelongsTo
    }

    class ProjectReport {
        <<model>>
        +int id
        +int project_id
        +String file_name
        +String file_path
        +project() BelongsTo
    }

    class SystemNotification {
        <<model>>
        +int id
        +String title
        +String description
        +String type
        +bool is_read
    }

    %% Relationships - Flutter Navigation
    MainNavigationScreen *-- OverviewTab
    MainNavigationScreen *-- ProjectsTab
    MainNavigationScreen *-- StaffDirectoryTab
    MainNavigationScreen *-- ReportsTab
    
    OverviewTab --> ProfileScreen : opens
    OverviewTab --> NotificationSheet : shows
    StaffDirectoryTab --> StaffDetailScreen : navigates
    ProjectsTab --> ProjectDetailScreen : navigates
    ProfileScreen --> AccountSecurityScreen : navigates

    %% Relationships - Flutter Services Communication
    OverviewTab ..> ApiService : uses
    OverviewTab ..> NotificationService : uses
    StaffDirectoryTab ..> ApiService : uses
    StaffDetailScreen ..> ApiService : uses
    ProjectsTab ..> ApiService : uses
    ProjectDetailScreen ..> ApiService : uses
    ReportsTab ..> ApiService : uses
    ProfileScreen ..> ApiService : uses
    NotificationSheet ..> ApiService : uses

    %% API Handoff Boundary
    ApiService ..> StaffController : HTTP Request (JSON)
    ApiService ..> ProjectController : HTTP Request (JSON)

    %% Relationships - Laravel Model-Controller
    StaffController ..> Anggota : queries/updates
    StaffController ..> Task : creates
    StaffController ..> Evaluation : creates
    StaffController ..> SystemNotification : creates
    ProjectController ..> Project : queries/updates

    %% Relationships - Laravel Database
    User "1" --> "*" Project : manages
    Divisi "1" --> "*" Anggota : contains
    Divisi "1" --> "*" Project : executes
    Anggota "1" --> "*" Task : has
    Anggota "1" --> "*" Evaluation : has
    Project "1" --> "*" ProjectTask : includes
    Project "1" --> "*" ProjectBug : tracks
    Project "1" --> "*" ProjectReport : stores
```

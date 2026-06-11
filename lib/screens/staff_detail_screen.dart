import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/notification_sheet.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class StaffDetailScreen extends StatefulWidget {
  final int staffId;
  final String staffName;
  final String role;
  final String avatar;

  const StaffDetailScreen({
    super.key,
    required this.staffId,
    required this.staffName,
    required this.role,
    required this.avatar,
  });

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  int _activeLocalTab = 0; // 0: Active Tasks, 1: Completed Tasks, 2: Evaluations
  bool _isLoading = true;

  // Real-time API States
  String _name = '';
  String _role = '';
  String _department = '';
  int _workloadPercentage = 0;
  String _status = 'NORMAL';
  double _reliability = 100.0;
  int _weeklyOutput = 0;
  String _avatarUrl = '';

  List<dynamic> _activeTasks = [];
  List<dynamic> _completedTasks = [];
  List<dynamic> _evaluations = [];

  @override
  void initState() {
    super.initState();
    _loadStaffDetail();
  }

  Future<void> _loadStaffDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getStaffDetail(widget.staffId);
      if (mounted && response['status'] == 'success') {
        final data = response['data'];
        setState(() {
          _name = data['name'] ?? widget.staffName;
          _role = data['role'] ?? widget.role;
          _department = data['department'] ?? '';
          _workloadPercentage = (data['workloadPercentage'] as num).toInt();
          _status = data['status'] ?? 'NORMAL';
          _reliability = (data['reliability'] as num).toDouble();
          _weeklyOutput = (data['weeklyOutput'] as num).toInt();
          _avatarUrl = data['avatarUrl'] ?? widget.avatar;

          _activeTasks = data['activeTasks'] ?? [];
          _completedTasks = data['completedTasks'] ?? [];
          _evaluations = data['evaluations'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load staff detail: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Ambil notif terbaru dari backend dan tampilkan yang BARU (ID baru) ke System Drawer.
  /// Dipanggil setelah berhasil assign task agar notif langsung muncul.
  Future<void> _checkAndShowNewNotifications() async {
    try {
      final notificationsResponse = await ApiService.getNotifications();
      if (notificationsResponse['status'] == 'success') {
        final List<dynamic> notifs = notificationsResponse['data']['notifications'] ?? [];
        for (var notif in notifs) {
          final int id = notif['id'] as int;
          final bool isRead = notif['isRead'] as bool;
          if (!isRead) {
            await NotificationService.showNotification(
              id: id,
              title: notif['title'] as String,
              body: notif['desc'] as String,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to check new notifications: $e');
    }
  }

  void _showAddTaskBottomSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final dateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CorporateTheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TUGASKAN KERJA BARU',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: CorporateTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assign New Task',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Judul Tugas',
                      hintText: 'Contoh: Audit Keuangan Triwulan',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Detail',
                      hintText: 'Masukkan instruksi pengerjaan...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Tenggat Waktu',
                      hintText: 'Contoh: 30 Jun 2026',
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty) return;

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              ),
                              SizedBox(width: 12),
                              Text('Menugaskan tugas baru ke database...'),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // Post to API
                      final res = await ApiService.assignTask(
                        widget.staffId,
                        titleController.text,
                        descController.text,
                        dateController.text.isNotEmpty ? dateController.text : 'Tenggat: Belum ditentukan',
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                      if (res['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('Tugas "${titleController.text}" berhasil ditugaskan!'),
                              ],
                            ),
                            backgroundColor: CorporateTheme.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        setState(() {
                          _activeLocalTab = 0; // Pindahkan fokus ke tab Active Tasks agar langsung terlihat
                        });
                        _loadStaffDetail(); // Reload

                        // Trigger cek notif baru dari backend agar muncul di System Drawer
                        _checkAndShowNewNotifications();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CorporateTheme.primaryContainer,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('ASSIGN TASK', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFeedbackBottomSheet() {
    final noteController = TextEditingController();
    double selectedRating = 5.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(20.0),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: CorporateTheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'BERI EVALUASI DIVISI',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: CorporateTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add Staff Evaluation',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Rating Stars Selection
                      Row(
                        children: [
                          Text(
                            'RATING EVALUASI: ',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: List.generate(5, (index) {
                              final int starVal = index + 1;
                              final bool isSelected = starVal <= selectedRating;
                              return GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    selectedRating = starVal.toDouble();
                                  });
                                },
                                child: Icon(
                                  Icons.star,
                                  color: isSelected ? Colors.amber : Colors.grey[300],
                                  size: 28,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Catatan Evaluasi / Masukan',
                          hintText: 'Tulis evaluasi performa kerja di sini...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () async {
                          if (noteController.text.isEmpty) return;

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Mengirim feedback ke database...'),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          // Post to API
                          final res = await ApiService.submitFeedback(
                            widget.staffId,
                            noteController.text,
                            selectedRating,
                          );

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                          if (res['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Evaluasi divisi berhasil ditambahkan!'),
                                  ],
                                ),
                                backgroundColor: CorporateTheme.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            setState(() {
                              _activeLocalTab = 2; // Pindahkan fokus ke tab Evaluations agar langsung terlihat
                            });
                            _loadStaffDetail(); // Reload
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CorporateTheme.primaryContainer,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('SUBMIT FEEDBACK', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Color workloadColor = CorporateTheme.success;
    Color workloadBg = CorporateTheme.success.withOpacity(0.1);
    if (_status == 'HIGH') {
      workloadColor = CorporateTheme.warning;
      workloadBg = CorporateTheme.warning.withOpacity(0.1);
    } else if (_status == 'AT RISK') {
      workloadColor = CorporateTheme.error;
      workloadBg = CorporateTheme.error.withOpacity(0.1);
    }

    return Scaffold(
      backgroundColor: CorporateTheme.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
              ),
            )
          : Stack(
              children: [
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _loadStaffDetail,
                    color: CorporateTheme.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 96),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Bagian Atas
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: CorporateTheme.primary),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.notifications_none_outlined, color: CorporateTheme.primary),
                                  onPressed: () => showNotificationsBottomSheet(context),
                                ),
                              ],
                            ),
                          ),

                          // Kartu Info Utama Staf
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: Stack(
                                children: [
                                  // Titik-titik latar belakang
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CustomPaint(
                                        painter: GridDotsPainter(
                                          dotColor: const Color(0xFFF1F5F9),
                                          spacing: 16,
                                          radius: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 36,
                                          backgroundImage: NetworkImage(_avatarUrl.isNotEmpty ? _avatarUrl : widget.avatar),
                                          backgroundColor: CorporateTheme.background,
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: workloadBg,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  _status,
                                                  style: textTheme.labelLarge?.copyWith(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: workloadColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _name.isNotEmpty ? _name : widget.staffName,
                                                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '$_role • $_department',
                                                style: textTheme.bodyMedium?.copyWith(color: CorporateTheme.onSurfaceVariant),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Lingkaran Radial Performa & Detail Grid
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                // Circular Progress Ring
                                Container(
                                  width: 130,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 84,
                                          height: 84,
                                          child: CustomPaint(
                                            painter: PerformanceRingPainter(
                                              progress: _reliability / 100,
                                              trackColor: const Color(0xFFF1F5F9),
                                              progressColor: CorporateTheme.success,
                                              strokeWidth: 8,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${_reliability.toStringAsFixed(1)}%',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: CorporateTheme.primaryContainer,
                                              ),
                                            ),
                                            Text(
                                              'RELIABILITY',
                                              style: GoogleFonts.inter(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: CorporateTheme.onSurfaceVariant,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Grid Detail Metrik Output/Kapasitas
                                Expanded(
                                  child: SizedBox(
                                    height: 140,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: _buildMetricCard(
                                            title: 'WEEKLY OUTPUT',
                                            value: '$_weeklyOutput Tasks',
                                            desc: 'Tasks completed',
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: _buildMetricCard(
                                            title: 'PROGRES PROYEK',
                                            value: '$_workloadPercentage%',
                                            desc: 'Rata-rata progres proyek',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tab Sub-Layar Konten Lokal (Tasks / Evaluations)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                              child: Row(
                                children: [
                                  _buildTabButton(0, 'Active Tasks (${_activeTasks.length})'),
                                  _buildTabButton(1, 'Completed (${_completedTasks.length})'),
                                  _buildTabButton(2, 'Evaluations (${_evaluations.length})'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Konten Berdasarkan Tab yang Aktif
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _buildTabContent(textTheme),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Glassmorphic Floating Feedback Button
                if (_activeLocalTab == 2)
                  Positioned(
                    left: 0,
                    right: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.8),
                        padding: const EdgeInsets.all(20.0),
                        child: SafeArea(
                          top: false,
                          child: ElevatedButton(
                            onPressed: _showFeedbackBottomSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CorporateTheme.primaryContainer,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: Text(
                              'BERI CATATAN / FEEDBACK',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String desc,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: CorporateTheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CorporateTheme.primaryContainer,
            ),
          ),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 8,
              color: CorporateTheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final bool isActive = _activeLocalTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeLocalTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? CorporateTheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? CorporateTheme.primary : CorporateTheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(TextTheme textTheme) {
    if (_activeLocalTab == 0) {
      // Active Tasks Tab
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE TASKS',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: CorporateTheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _activeTasks.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('Tidak ada tugas aktif.', style: TextStyle(fontSize: 12, color: CorporateTheme.onSurfaceVariant)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activeTasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = _activeTasks[index];
                    return _buildTaskCard(
                      title: task['title'] as String,
                      desc: task['description'] as String,
                      status: task['status'] as String,
                      statusColor: CorporateTheme.success,
                      statusBg: CorporateTheme.success.withOpacity(0.1),
                      date: task['dueDate'] as String,
                      progress: task['progress'] != null ? (task['progress'] as num).toDouble() : 0.5,
                      textTheme: textTheme,
                    );
                  },
                ),
        ],
      );
    } else if (_activeLocalTab == 1) {
      // Completed Tasks Tab
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMPLETED TASKS',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: CorporateTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          _completedTasks.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('Belum ada tugas diselesaikan.', style: TextStyle(fontSize: 12, color: CorporateTheme.onSurfaceVariant)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _completedTasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = _completedTasks[index];
                    return _buildTaskCard(
                      title: task['title'] as String,
                      desc: task['description'] as String,
                      status: task['status'] as String,
                      statusColor: CorporateTheme.primaryContainer,
                      statusBg: CorporateTheme.primaryContainer.withOpacity(0.1),
                      date: task['dueDate'] as String,
                      progress: 1.0,
                      textTheme: textTheme,
                    );
                  },
                ),
        ],
      );
    } else {
      // Evaluations/Feedback Tab
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIVISIONS FEEDBACKS',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: CorporateTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _evaluations.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('Belum ada evaluasi untuk staf ini.', style: TextStyle(fontSize: 12, color: CorporateTheme.onSurfaceVariant)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _evaluations.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final eval = _evaluations[index];
                    final double rating = (eval['rating'] as num).toDouble();
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Division Lead',
                                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: List.generate(5, (starIdx) {
                                  return Icon(
                                    Icons.star,
                                    color: (starIdx + 1) <= rating ? Colors.amber : Colors.grey[200],
                                    size: 14,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            eval['date'] as String,
                            style: textTheme.labelLarge?.copyWith(fontSize: 10, color: CorporateTheme.outline),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            eval['note'] as String,
                            style: textTheme.bodyMedium?.copyWith(color: CorporateTheme.onSurfaceVariant, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      );
    }
  }

  Widget _buildTaskCard({
    required String title,
    required String desc,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String date,
    required double progress,
    bool isOverdueAlert = false,
    required TextTheme textTheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.headlineSmall,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 9,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: textTheme.bodyMedium?.copyWith(
              color: CorporateTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: isOverdueAlert ? CorporateTheme.error : CorporateTheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                      color: isOverdueAlert ? CorporateTheme.error : CorporateTheme.onSurfaceVariant,
                      fontWeight: isOverdueAlert ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDjPYthawamKptO2svXYC5fv264uFWWqQl9In0-GIhvdJMYbhV91YV9oAn2yg7r43B96sIFx5ecN_i4KNfN2pysyEnFB3xtlQ8-fQLACG6d-HN-MC_1CZkmrqyplTuoFpHs2qIu4ZyYphrM8yyKitoUygP9PlXww_CrNTgeIqyjop4D1BP74xVjeeWioLaIC1vtzYb7yHgXD5LuDqTH00v1sHmVKNKIYYwjyZtXmz-3munyX0ZhkPP5KF1IoscqtqdI7EGTUN1IlIyy',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (progress > 0.0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PROGRESS',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 9,
                    color: CorporateTheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 9,
                    color: CorporateTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.success),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GridDotsPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double radius;

  GridDotsPainter({
    required this.dotColor,
    required this.spacing,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PerformanceRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  PerformanceRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.1415926535 / 2;
    final sweepAngle = 2 * 3.1415926535 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

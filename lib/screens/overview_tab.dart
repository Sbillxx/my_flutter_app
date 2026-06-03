import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../theme.dart';
import 'staff_detail_screen.dart';
import 'profile_screen.dart';
import '../widgets/notification_sheet.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class OverviewTab extends StatefulWidget {
  final VoidCallback onNavigateToStaff;

  const OverviewTab({
    super.key,
    required this.onNavigateToStaff,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  bool _isLoading = true;
  bool _isFirstLoad = true; // Flag untuk membedakan load pertama vs refresh
  String _profileName = 'Kepala';
  String _profileAvatarUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjPYthawamKptO2svXYC5fv264uFWWqQl9In0-GIhvdJMYbhV91YV9oAn2yg7r43B96sIFx5ecN_i4KNfN2pysyEnFB3xtlQ8-fQLACG6d-HN-MC_1CZkmrqyplTuoFpHs2qIu4ZyYphrM8yyKitoUygP9PlXww_CrNTgeIqyjop4D1BP74xVjeeWioLaIC1vtzYb7yHgXD5LuDqTH00v1sHmVKNKIYYwjyZtXmz-3munyX0ZhkPP5KF1IoscqtqdI7EGTUN1IlIyy';

  ImageProvider _getImageProvider(String url) {
    if (url.startsWith('data:image/') && url.contains(';base64,')) {
      try {
        final String base64Str = url.split(';base64,').last;
        return MemoryImage(base64Decode(base64Str));
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
      }
    }
    return NetworkImage(url);
  }

  Map<String, dynamic> _kpis = {
    'totalProjects': 4,
    'delayedTasks': 8,
    'activeStaff': 42,
  };
  List<dynamic> _topPerformers = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dashboardResponse = await ApiService.getDashboard();
      final profileResponse = await ApiService.getProfile();
      final notificationsResponse = await ApiService.getNotifications();

      if (mounted) {
        setState(() {
          if (dashboardResponse['status'] == 'success') {
            _kpis = dashboardResponse['data']['kpis'] ?? _kpis;
            _topPerformers = dashboardResponse['data']['topPerformers'] ?? [];
          }
          if (profileResponse['status'] == 'success') {
            final prof = profileResponse['data'];
            _profileName = prof['name'] ?? 'Kepala';
            _profileAvatarUrl = prof['avatarUrl'] ?? _profileAvatarUrl;
          }
          _isLoading = false;
        });

        // Trigger real Android OS system drawer notifications for unread items
        if (notificationsResponse['status'] == 'success') {
          final List<dynamic> notifs = notificationsResponse['data']['notifications'] ?? [];

          if (_isFirstLoad) {
            // Saat load pertama, pre-populate semua ID yang sudah ada ke dalam
            // set "sudah ditampilkan" agar tidak men-spam notif lama.
            // Notif yang BENAR-BENAR BARU (ID baru) akan muncul pada refresh berikutnya.
            for (var notif in notifs) {
              final int id = notif['id'] as int;
              NotificationService.markAsShown(id);
            }
            _isFirstLoad = false;
          } else {
            // Pada refresh berikutnya (setelah assign task/project, dll),
            // hanya tampilkan notif yang belum pernah kita tampilkan sebelumnya (ID baru).
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
        }
      }
    } catch (e) {
      debugPrint('Failed to load dashboard/profile/notifications: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CorporateTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: CorporateTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top AppBar (Custom)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          ).then((_) {
                            _loadDashboardData();
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CorporateTheme.primaryContainer.withOpacity(0.2),
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image: _getImageProvider(_profileAvatarUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat Pagi, $_profileName',
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Division Lead',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: CorporateTheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: CorporateTheme.primary,
                      ),
                      onPressed: () => showNotificationsBottomSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. KPI Section (Horizontal Scrollable)
                _isLoading
                    ? const SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            (() {
                              final String projTrend = _kpis['totalProjectsTrend']?.toString() ?? '+0';
                              final Color projBadgeColor = projTrend.startsWith('-') || projTrend == '+0' || projTrend == '0%' 
                                  ? CorporateTheme.onSurfaceVariant.withOpacity(0.4) 
                                  : CorporateTheme.success;
                              return _buildScrollKPICard(
                                title: 'TOTAL PROJECT',
                                value: (_kpis['totalProjects'] ?? 0).toString(),
                                badgeText: projTrend,
                                badgeColor: projBadgeColor,
                                progressValue: 0.7,
                                progressColor: CorporateTheme.primary,
                              );
                            }()),
                            const SizedBox(width: 16),
                            (() {
                              final String delayTrend = _kpis['delayedTasksTrend']?.toString() ?? '0';
                              final Color delayBadgeColor = delayTrend.startsWith('-') 
                                  ? CorporateTheme.success 
                                  : (delayTrend == '0' ? CorporateTheme.onSurfaceVariant.withOpacity(0.4) : CorporateTheme.error);
                              return _buildScrollKPICard(
                                title: 'DELAYED',
                                value: _kpis['delayedTasks'].toString().padLeft(2, '0'),
                                badgeText: delayTrend,
                                badgeColor: delayBadgeColor,
                                progressValue: 0.25,
                                progressColor: CorporateTheme.error,
                              );
                            }()),
                            const SizedBox(width: 16),
                            _buildScrollKPICard(
                              title: 'ACTIVE STAFF',
                              value: _kpis['activeStaff'].toString(),
                              badgeText: _kpis['activeStaffTrend']?.toString() ?? 'LIVE',
                              badgeColor: CorporateTheme.success,
                              progressValue: 0.9,
                              progressColor: CorporateTheme.success,
                              isLive: true,
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 24),

                // 3. Team Productivity Chart (Interactive)
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Progres Proyek',
                                    style: textTheme.headlineMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rata-rata progres proyek per anggota tim',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: CorporateTheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.more_vert, color: CorporateTheme.outline),
                              onPressed: () => _showWeeklyProductivityMenu(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Animating Bar Chart Area (Dynamic)
                        SizedBox(
                          height: 160,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _topPerformers.map((staff) {
                              final String name = staff['name'] as String;
                              final String label = name.split(' ').first;
                              final double progress = ((staff['workloadPercentage'] ?? 0) as num).toDouble() / 100.0;
                              final bool isSuccess = progress >= 0.8;

                              return Expanded(
                                child: InteractiveBar(
                                  label: label.toUpperCase(),
                                  fillPercent: progress,
                                  isSuccess: isSuccess,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Staff Performance Overview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Staff Performance',
                        style: textTheme.headlineMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: widget.onNavigateToStaff,
                      child: Text(
                        'View All',
                        style: textTheme.labelLarge?.copyWith(
                          color: CorporateTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // List of Staff Items
                _isLoading
                    ? const SizedBox(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: _topPerformers.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(
                                  child: Text(
                                    'Tidak ada performa staf di atas rata-rata saat ini.',
                                    style: TextStyle(fontSize: 12, color: CorporateTheme.onSurfaceVariant),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _topPerformers.length,
                                separatorBuilder: (context, index) => const Divider(
                                  height: 1,
                                  color: Color(0xFFE2E8F0),
                                ),
                                itemBuilder: (context, index) {
                                  final staff = _topPerformers[index];
                                  final double progress = ((staff['workloadPercentage'] ?? 0) as num).toDouble();
                                  final String status = (staff['status'] ?? 'NORMAL') as String;

                                  Color statusColor = CorporateTheme.success;
                                  if (status == 'HIGH') statusColor = CorporateTheme.warning;
                                  if (status == 'AT RISK') statusColor = CorporateTheme.error;

                                  return ListTile(
                                    contentPadding: const EdgeInsets.all(16.0),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StaffDetailScreen(
                                            staffId: staff['id'] as int,
                                            staffName: staff['name'] as String,
                                            role: staff['role'] as String,
                                            avatar: staff['avatarUrl'] as String,
                                          ),
                                        ),
                                      ).then((_) => _loadDashboardData());
                                    },
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: CorporateTheme.background,
                                      backgroundImage: NetworkImage(staff['avatarUrl'] as String),
                                    ),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            staff['name'] as String,
                                            style: textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            status,
                                            style: textTheme.labelLarge?.copyWith(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          staff['role'] as String,
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontSize: 12,
                                            color: CorporateTheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'PROGRES PROYEK',
                                              style: textTheme.labelLarge?.copyWith(
                                                fontSize: 9,
                                                color: CorporateTheme.onSurfaceVariant,
                                              ),
                                            ),
                                            Text(
                                              '${progress.toInt()}%',
                                              style: textTheme.labelLarge?.copyWith(
                                                fontSize: 9,
                                                color: CorporateTheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(9999),
                                          child: LinearProgressIndicator(
                                            value: progress / 100,
                                            minHeight: 6,
                                            backgroundColor: const Color(0xFFF1F5F9),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollKPICard({
    required String title,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required double progressValue,
    required Color progressColor,
    bool isLive = false,
  }) {
    return Container(
      width: 168,
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
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: CorporateTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: CorporateTheme.dataDisplay().copyWith(fontSize: 28),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              isLive
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Flexible(
                      child: Text(
                        badgeText,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 4,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showWeeklyProductivityMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'OPSI GRAFIK PRODUKTIVITAS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: CorporateTheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.refresh, color: CorporateTheme.primary),
                title: const Text('Segarkan Data Grafik'),
                onTap: () {
                  Navigator.pop(context);
                  _loadDashboardData();
                },
              ),
              // PDF & Excel exports hidden per user request
              /*
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: CorporateTheme.error),
                title: const Text('Ekspor Laporan PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _showSimulationDialog(
                    context: context,
                    title: 'Mengekspor Laporan',
                    message: 'Sedang memproses laporan grafik ke dalam format PDF...',
                    successMessage: 'Laporan PDF berhasil disimpan di folder Unduhan!',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: CorporateTheme.success),
                title: const Text('Ekspor Excel (XLSX)'),
                onTap: () {
                  Navigator.pop(context);
                  _showSimulationDialog(
                    context: context,
                    title: 'Mengekspor Data',
                    message: 'Mengekspor data mentah efisiensi ke format Excel...',
                    successMessage: 'Data spreadsheet berhasil disimpan!',
                  );
                },
              ),
              */
            ],
          ),
        );
      },
    );
  }

  /*
  void _showSimulationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String successMessage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future.delayed(const Duration(seconds: 2), () {
              if (!context.mounted) return;
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(child: Text(successMessage)),
                      ],
                    ),
                    backgroundColor: CorporateTheme.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: CorporateTheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  */
}

// Stateful Widget untuk diagram interaktif
class InteractiveBar extends StatefulWidget {
  final String label;
  final double fillPercent;
  final bool isSuccess;

  const InteractiveBar({
    super.key,
    required this.label,
    required this.fillPercent,
    this.isSuccess = false,
  });

  @override
  State<InteractiveBar> createState() => _InteractiveBarState();
}

class _InteractiveBarState extends State<InteractiveBar> {
  late double _currentPercent;

  @override
  void initState() {
    super.initState();
    _currentPercent = widget.fillPercent;
  }

  void _triggerClickAnimation() {
    setState(() {
      _currentPercent = 1.0;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentPercent = widget.fillPercent;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: _triggerClickAnimation,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: CorporateTheme.primaryContainer.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                alignment: Alignment.bottomCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: constraints.maxHeight * _currentPercent,
                      decoration: BoxDecoration(
                        color: widget.isSuccess ? CorporateTheme.success : CorporateTheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: CorporateTheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

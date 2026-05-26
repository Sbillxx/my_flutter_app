import 'package:flutter/material.dart';
import 'dart:async';
import '../theme.dart';
import 'overview_tab.dart';
import 'projects_tab.dart';
import 'staff_directory_tab.dart';
import 'reports_tab.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  Timer? _notificationTimer;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      OverviewTab(onNavigateToStaff: () {
        setState(() {
          _currentIndex = 2; // Pindah ke tab Staff Directory
        });
      }),
      const ProjectsTab(),
      StaffDirectoryTab(),
      const ReportsTab(),
    ];
    _startNotificationPolling();
  }

  void _startNotificationPolling() {
    // Polling berkala setiap 5 detik untuk notifikasi baru agar tersinkronisasi di OS status bar
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
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
        debugPrint('Failed to poll system notifications: $e');
      }
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      // Navigasi Bawah Kustom yang menyamai persis tampilan prototipe Tailwind
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.dashboard,
                  label: 'Overview',
                  textTheme: textTheme,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.assignment,
                  label: 'Projects',
                  textTheme: textTheme,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.group,
                  label: 'Staff',
                  textTheme: textTheme,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.analytics,
                  label: 'Reports',
                  textTheme: textTheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required TextTheme textTheme,
  }) {
    final bool isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: isActive
                ? CorporateTheme.success.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? CorporateTheme.success
                    : CorporateTheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? CorporateTheme.success
                      : CorporateTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';

void showNotificationsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return const NotificationSheetBody();
    },
  );
}

class NotificationSheetBody extends StatefulWidget {
  const NotificationSheetBody({super.key});

  @override
  State<NotificationSheetBody> createState() => _NotificationSheetBodyState();
}

class _NotificationSheetBodyState extends State<NotificationSheetBody> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final res = await ApiService.getNotifications();
      if (mounted && res['status'] == 'success') {
        setState(() {
          _notifications = res['data']['notifications'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    // Optimistic UI update
    setState(() {
      for (var item in _notifications) {
        item['isRead'] = true;
      }
    });

    try {
      await ApiService.readAllNotifications();
    } catch (e) {
      debugPrint('Failed to mark all read in API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar dekoratif
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: CorporateTheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header Notifikasi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOTIFIKASI SISTEM',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: CorporateTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aktivitas Terbaru Divisi',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.done_all, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Semua notifikasi ditandai telah dibaca'),
                          ],
                        ),
                        backgroundColor: CorporateTheme.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                    await _markAllAsRead();
                  },
                  child: Text(
                    'Tandai Dibaca',
                    style: textTheme.labelLarge?.copyWith(
                      color: CorporateTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),

          // List Item Notifikasi
          _isLoading
              ? const SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? const SizedBox(
                      height: 150,
                      child: Center(
                        child: Text(
                          'Tidak ada notifikasi sistem.',
                          style: TextStyle(fontSize: 12, color: CorporateTheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        final String type = item['type'] as String;
                        final String hexColor = item['color'] as String;
                        final bool isRead = item['isRead'] as bool;

                        // Parse color from hex
                        Color color = CorporateTheme.primary;
                        try {
                          color = Color(int.parse(hexColor.replaceAll('#', '0xFF')));
                        } catch (_) {}

                        IconData icon = Icons.task_alt;
                        if (type == 'warning') icon = Icons.warning_amber_rounded;
                        if (type == 'error') icon = Icons.error_outline_rounded;
                        if (type == 'info') icon = Icons.insights;

                        return Container(
                          color: isRead ? Colors.transparent : CorporateTheme.primary.withOpacity(0.03),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                item['title'] as String,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    item['desc'] as String,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 11,
                                      color: CorporateTheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['time'] as String,
                                    style: textTheme.labelLarge?.copyWith(
                                      fontSize: 9,
                                      color: CorporateTheme.onSurfaceVariant.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

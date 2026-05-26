import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  bool _isLoading = true;
  List<dynamic> _reports = [];
  String _globalEfficiency = '92.4%';
  String _averageWorkload = '72.8%';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getReports();
      if (mounted && response['status'] == 'success') {
        setState(() {
          _reports = response['data']['reports'] ?? [];
          if (response['data']['metrics'] != null) {
            _globalEfficiency = response['data']['metrics']['globalEfficiency'] ?? '92.4%';
            _averageWorkload = response['data']['metrics']['averageWorkload'] ?? '72.8%';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load reports: $e');
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
          onRefresh: _loadReports,
          color: CorporateTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Tab
                Text(
                  'SYSTEM ANALYTICS',
                  style: textTheme.labelLarge?.copyWith(
                    color: CorporateTheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Laporan & Analitis',
                  style: textTheme.headlineLarge,
                ),
                const SizedBox(height: 24),

                // KPI Ringkasan Laporan
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EFISIENSI GLOBAL',
                                style: textTheme.labelLarge?.copyWith(
                                  fontSize: 9,
                                  color: CorporateTheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _globalEfficiency,
                                style: CorporateTheme.dataDisplay(
                                  color: CorporateTheme.success,
                                ).copyWith(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BEBAN KERJA RATA-RATA',
                                style: textTheme.labelLarge?.copyWith(
                                  fontSize: 9,
                                  color: CorporateTheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _averageWorkload,
                                style: CorporateTheme.dataDisplay(
                                  color: CorporateTheme.warning,
                                ).copyWith(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sub-Header List Laporan
                Text(
                  'DOKUMEN LAPORAN',
                  style: textTheme.labelLarge?.copyWith(
                    color: CorporateTheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 12),

                // List item Laporan
                _isLoading
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: _reports.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(
                                  child: Text(
                                    'Tidak ada laporan tersedia.',
                                    style: TextStyle(fontSize: 12, color: CorporateTheme.onSurfaceVariant),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _reports.length,
                                separatorBuilder: (context, index) => const Divider(
                                  height: 1,
                                  color: Color(0xFFE2E8F0),
                                ),
                                itemBuilder: (context, index) {
                                  final report = _reports[index];
                                  final String category = report['category'] as String;

                                  IconData icon = Icons.picture_as_pdf;
                                  Color iconColor = CorporateTheme.error;

                                  if (category == 'PKPT') {
                                    icon = Icons.table_chart;
                                    iconColor = CorporateTheme.success;
                                  } else if (category == 'Evaluasi') {
                                    icon = Icons.insights;
                                    iconColor = CorporateTheme.warning;
                                  } else if (category == 'Perencanaan') {
                                    icon = Icons.analytics;
                                    iconColor = CorporateTheme.primaryContainer;
                                  } else if (category == 'Regulasi') {
                                    icon = Icons.gavel;
                                    iconColor = CorporateTheme.primary;
                                  }

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: iconColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: iconColor,
                                      ),
                                    ),
                                    title: Text(
                                      report['title'] as String,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          '${report['category']} • ${report['size']}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontSize: 11,
                                            color: CorporateTheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          report['date'] as String,
                                          style: textTheme.labelLarge?.copyWith(
                                            fontSize: 9,
                                            color: CorporateTheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.download,
                                        color: CorporateTheme.primary,
                                      ),
                                      onPressed: () {
                                        _simulateDownload(context, report['title'] as String);
                                      },
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

  void _simulateDownload(BuildContext context, String reportTitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        double progress = 0.0;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (!context.mounted) return;
              if (progress < 1.0) {
                setDialogState(() {
                  progress += 0.1;
                });
              } else {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.download_done, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Berkas "$reportTitle" berhasil diunduh!',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: CorporateTheme.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Mengunduh Laporan...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${(progress * 100).toInt()}% selesai',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CorporateTheme.primary),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

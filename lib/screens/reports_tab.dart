import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'staff_detail_screen.dart';
import 'project_detail_screen.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  bool _isLoading = true;
  List<dynamic> _reports = [];
  List<dynamic> _projects = [];
  List<dynamic> _staff = [];
  String _globalEfficiency = '92.4%';
  String _averageWorkload = '72.8%';

  int _activeTab = 0; // 0: Dokumen, 1: Progres Proyek, 2: Kinerja Staf
  String _timeRange = 'WEEKLY'; // DAILY, WEEKLY, MONTHLY

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  Future<void> _loadReportsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reportsResponse = await ApiService.getReports();
      final projectsResponse = await ApiService.getProjects();
      final staffResponse = await ApiService.getStaff();

      if (mounted) {
        setState(() {
          if (reportsResponse['status'] == 'success') {
            _reports = reportsResponse['data']['reports'] ?? [];
            if (reportsResponse['data']['metrics'] != null) {
              _globalEfficiency = reportsResponse['data']['metrics']['globalEfficiency'] ?? '92.4%';
              _averageWorkload = reportsResponse['data']['metrics']['averageWorkload'] ?? '72.8%';
            }
          }
          if (projectsResponse['status'] == 'success') {
            _projects = projectsResponse['data']['projects'] ?? [];
          }
          if (staffResponse['status'] == 'success') {
            _staff = staffResponse['data']['staff'] ?? [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load reports data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getLogForTimeRange(String projectName, String timeRange, double progress) {
    final bool isCompleted = progress >= 1.0;
    if (timeRange == 'DAILY') {
      return isCompleted 
          ? 'Log Hari Ini: Proyek selesai disinkronisasikan ke server utama Kominfo.' 
          : 'Log Hari Ini: Penyesuaian API endpoint dan pengujian fungsionalitas modul peta berjalan lancar.';
    } else if (timeRange == 'WEEKLY') {
      return isCompleted 
          ? 'Log Minggu Ini: Pengujian keamanan database kelar, seluruh modul dinyatakan lulus audit Q3.' 
          : 'Log Minggu Ini: Refactoring struktur basis data selesai dikerjakan untuk meningkatkan load speed.';
    } else {
      return isCompleted 
          ? 'Log Bulan Ini: Desain UI, integrasi frontend-backend, dan deployment ke cloud rampung dilaksanakan.' 
          : 'Log Bulan Ini: Wireframe antarmuka diserahkan ke tim QA untuk sinkronisasi layout dasbor mobile.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CorporateTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadReportsData,
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
                const SizedBox(height: 20),

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

                // Segmented Local Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      _buildLocalTabButton(0, 'Dokumen', Icons.folder_open),
                      _buildLocalTabButton(1, 'Progres Proyek', Icons.assignment_outlined),
                      _buildLocalTabButton(2, 'Kinerja Staf', Icons.group_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Content render berdasarkan active tab
                _isLoading
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
                          ),
                        ),
                      )
                    : _buildActiveTabContent(textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalTabButton(int index, String label, IconData icon) {
    final bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? CorporateTheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : CorporateTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : CorporateTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(TextTheme textTheme) {
    if (_activeTab == 0) {
      return _buildDocumentTab(textTheme);
    } else if (_activeTab == 1) {
      return _buildProjectProgressTab(textTheme);
    } else {
      return _buildStaffPerformanceTab(textTheme);
    }
  }

  // TAB 1: DOKUMEN LAPORAN STATIS (EXISTING)
  Widget _buildDocumentTab(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DOKUMEN LAPORAN RESMI',
          style: textTheme.labelLarge?.copyWith(
            color: CorporateTheme.onSurfaceVariant,
            letterSpacing: 1.5,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
                          if (report['description'] != null && (report['description'] as String).isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              report['description'] as String,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                color: CorporateTheme.onSurfaceVariant.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
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
                          _downloadReport(report['title'] as String, report['url'] as String?);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // TAB 2: PROGRES PROYEK & TIMELINE LOGS (DINAMIS DENGAN RENTANG WAKTU)
  Widget _buildProjectProgressTab(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter rentang waktu harian/mingguan/bulanan
        Row(
          children: [
            Text(
              'RENTANG DATA: ',
              style: textTheme.labelLarge?.copyWith(fontSize: 10, color: CorporateTheme.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ['DAILY', 'WEEKLY', 'MONTHLY'].map((range) {
                    final bool isSelected = _timeRange == range;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          range == 'DAILY' ? 'HARIAN' : (range == 'WEEKLY' ? 'MINGGUAN' : 'BULANAN'),
                          style: textTheme.labelLarge?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : CorporateTheme.primaryContainer,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: CorporateTheme.primaryContainer,
                        backgroundColor: CorporateTheme.primaryContainer.withOpacity(0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _timeRange = range;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          'REKAPITULASI PROGRES INISIATIF',
          style: textTheme.labelLarge?.copyWith(
            color: CorporateTheme.onSurfaceVariant,
            letterSpacing: 1.5,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 12),

        _projects.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Tidak ada data proyek strategis.', style: TextStyle(fontSize: 12, color: CorporateTheme.onSurfaceVariant)),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _projects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final proj = _projects[index];
                  final double progress = (proj['progress'] as num).toDouble();
                  final bool isCompleted = progress >= 1.0;

                  Color statusColor = isCompleted ? CorporateTheme.success : CorporateTheme.warning;
                  Color statusBg = statusColor.withOpacity(0.1);

                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: CorporateTheme.primaryContainer.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (proj['division'] as String? ?? '').toUpperCase(),
                                  style: textTheme.labelLarge?.copyWith(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: CorporateTheme.primaryContainer,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isCompleted ? 'SELESAI' : 'BERJALAN',
                                  style: textTheme.labelLarge?.copyWith(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailScreen(projectId: proj['id'] as int),
                                ),
                              );
                            },
                            child: Text(
                              proj['name'] as String,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: CorporateTheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            proj['description'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: CorporateTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Progress Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PROGRESS KELAYAKAN',
                                style: textTheme.labelLarge?.copyWith(fontSize: 8, color: CorporateTheme.outline),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: textTheme.labelLarge?.copyWith(fontSize: 9, fontWeight: FontWeight.bold, color: CorporateTheme.primary),
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
                              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Progress Log box
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: CorporateTheme.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.history_toggle_off, size: 12, color: CorporateTheme.primaryContainer),
                                    const SizedBox(width: 6),
                                    Text(
                                      'LOG PEMBARUAN',
                                      style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: CorporateTheme.primaryContainer),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _getLogForTimeRange(proj['name'] as String, _timeRange, progress),
                                  style: textTheme.bodyMedium?.copyWith(fontSize: 11, color: CorporateTheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  // TAB 3: KINERJA KOMPARATIF STAF DIVISI
  Widget _buildStaffPerformanceTab(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REKAPITULASI KINERJA KARYAWAN',
          style: textTheme.labelLarge?.copyWith(
            color: CorporateTheme.onSurfaceVariant,
            letterSpacing: 1.5,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 12),
        _staff.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Tidak ada data staf.', style: TextStyle(fontSize: 12, color: CorporateTheme.onSurfaceVariant)),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _staff.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final staff = _staff[index];
                  final String status = (staff['status'] ?? 'NORMAL') as String;
                  final double reliability = ((staff['reliability'] ?? 100.0) as num).toDouble();
                  final int tasks = (staff['totalTasks'] ?? staff['activeTasks']?.length ?? 0) as int;

                  Color statusColor = CorporateTheme.success;
                  if (status == 'HIGH') statusColor = CorporateTheme.warning;
                  if (status == 'AT RISK') statusColor = CorporateTheme.error;

                  return Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
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
                        ).then((_) => _loadReportsData());
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(staff['avatarUrl'] as String),
                                  backgroundColor: CorporateTheme.background,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        staff['name'] as String,
                                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${staff['role']} • ${staff['department']}',
                                        style: textTheme.bodyMedium?.copyWith(fontSize: 11, color: CorporateTheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    status,
                                    style: textTheme.labelLarge?.copyWith(fontSize: 8, fontWeight: FontWeight.bold, color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMiniStat(
                                    label: 'RELIABILITY',
                                    value: '${reliability.toStringAsFixed(1)}%',
                                    color: CorporateTheme.success,
                                  ),
                                ),
                                Expanded(
                                  child: _buildMiniStat(
                                    label: 'TOTAL TASKS',
                                    value: '$tasks Tasks',
                                    color: CorporateTheme.primaryContainer,
                                  ),
                                ),
                                Expanded(
                                  child: _buildMiniStat(
                                    label: 'WORKLOAD',
                                    value: '${staff['workloadPercentage']}%',
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildMiniStat({required String label, required String value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: CorporateTheme.outline),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  // DOWNLOAD REPORT UTILITY AND DIALOGS (EXISTING)
  Future<void> _downloadReport(String title, String? urlPath) async {
    if (urlPath == null || urlPath == '#' || urlPath.isEmpty) {
      _simulateDownload(context, title);
      return;
    }

    final String host = ApiService.baseUrl.replaceAll('/api', '');
    final String downloadUrl = '$host$urlPath';
    final String encodedUrl = Uri.encodeFull(downloadUrl);

    debugPrint('Downloading report from: $encodedUrl');

    try {
      final Uri uri = Uri.parse(encodedUrl);
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.downloading, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Membuka browser untuk mengunduh "$title"...',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: CorporateTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error launching download URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunduh berkas: $e'),
          backgroundColor: CorporateTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

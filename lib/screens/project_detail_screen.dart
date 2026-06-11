import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _project;

  @override
  void initState() {
    super.initState();
    _loadProjectDetails();
  }

  Future<void> _loadProjectDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getProjectDetails(widget.projectId);
      if (mounted && response['status'] == 'success') {
        setState(() {
          _project = response['data']['project'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load project details: $e');
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
      appBar: AppBar(
        title: Text('Detail Proyek', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: CorporateTheme.onSurface,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
              ),
            )
          : _project == null
              ? const Center(
                  child: Text(
                    'Proyek tidak ditemukan.',
                    style: TextStyle(color: CorporateTheme.onSurfaceVariant),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProjectDetails,
                  color: CorporateTheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project Overview Card
                        _buildProjectOverviewCard(textTheme),
                        const SizedBox(height: 24),

                        // Progress Logs Header
                        Row(
                          children: [
                            Container(
                              height: 16,
                              width: 4,
                              decoration: BoxDecoration(
                                color: CorporateTheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Progress Logs',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_project!['tasks']?.length ?? 0} Logs',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Progress Logs List
                        _buildProgressLogs(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProjectOverviewCard(TextTheme textTheme) {
    final double progress = (_project!['progress'] as num).toDouble();
    final String workload = _project!['workload'] ?? 'NORMAL';

    Color workloadColor = CorporateTheme.success;
    Color workloadBg = CorporateTheme.success.withOpacity(0.1);
    if (workload == 'HIGH') {
      workloadColor = CorporateTheme.warning;
      workloadBg = CorporateTheme.warning.withOpacity(0.1);
    } else if (workload == 'AT RISK') {
      workloadColor = CorporateTheme.error;
      workloadBg = CorporateTheme.error.withOpacity(0.1);
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CorporateTheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (_project!['division'] as String? ?? '').toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: CorporateTheme.primaryContainer,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: workloadBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    workload,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: workloadColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _project!['name'] ?? '',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _project!['description'] ?? '',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            if (_project!['assignedStaff'] != null && (_project!['assignedStaff'] as List).isNotEmpty) ...[
              Text(
                'TIM PENANGGUNG JAWAB',
                style: textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_project!['assignedStaff'] as List<dynamic>).map((staffName) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      staffName as String,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PROGRESS KESELURUHAN',
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CorporateTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(workloadColor),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(
                  'Target: ${_project!['targetDate'] ?? '-'}',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressLogs() {
    final tasks = _project!['tasks'] as List<dynamic>? ?? [];

    if (tasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Belum ada progress log.',
              style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isLast = index == tasks.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line and dot
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    decoration: BoxDecoration(
                      color: CorporateTheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: CorporateTheme.primaryContainer.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Content Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFF1F5F9)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                task['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (task['description'] != null && task['description'].toString().isNotEmpty)
                            Text(
                              task['description'],
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          if (task['image_url'] != null && task['image_url'].toString().isNotEmpty) ...[
                            Builder(
                              builder: (context) {
                                String imgUrl = task['image_url'].toString();
                                // Fix for Android Emulator pointing to host's localhost and port
                                if (imgUrl.startsWith('http://localhost/')) {
                                  imgUrl = imgUrl.replaceFirst('http://localhost/', 'http://192.168.18.7:8000/');
                                } else if (imgUrl.startsWith('http://localhost:8000/')) {
                                  imgUrl = imgUrl.replaceFirst('http://localhost:8000/', 'http://192.168.18.7:8000/');
                                }

                                 // Bypass PHP built-in server bugs by using Node http-server on port 8080
                                 imgUrl = imgUrl.replaceFirst('/api/image/', '/');
                                 imgUrl = imgUrl.replaceFirst('/storage/', '/');
                                 imgUrl = imgUrl.replaceFirst('http://192.168.18.7:8000', 'http://192.168.18.7:8080');
                                 imgUrl = imgUrl.replaceFirst('http://10.0.2.2:8000', 'http://192.168.18.7:8080');
                                return Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    FutureBuilder<Uint8List>(
                                      future: () async {
                                        var request = await HttpClient().getUrl(Uri.parse(imgUrl));
                                        request.headers.set(HttpHeaders.connectionHeader, 'close');
                                        var response = await request.close();
                                        if (response.statusCode != 200) {
                                          throw Exception('HTTP Error: ${response.statusCode}');
                                        }
                                        return await consolidateHttpClientResponseBytes(response);
                                      }(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        }
                                        if (snapshot.hasError) {
                                          return Text("Network Error: ${snapshot.error}\n$imgUrl", style: const TextStyle(color: Colors.red));
                                        }
                                        final bytes = snapshot.data;
                                        if (bytes == null) {
                                          return Text("Error: No data received\n$imgUrl", style: const TextStyle(color: Colors.red));
                                        }
                                        try {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.memory(
                                              bytes,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Text("Decode Error: $error\nBytes: ${bytes.length}\n$imgUrl", style: const TextStyle(color: Colors.red));
                                              },
                                            ),
                                          );
                                        } catch (e) {
                                          return Text("Exception: $e", style: const TextStyle(color: Colors.red));
                                        }
                                      },
                                    ),
                                  ],
                                );
                              }
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(
                                task['user_name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.access_time, size: 14, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(
                                task['created_at'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

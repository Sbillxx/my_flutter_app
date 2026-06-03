import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Gunakan IP 10.0.2.2 untuk Android Emulator, localhost untuk Web/Desktop/iOS
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api';
      }
    } catch (_) {}
    return 'http://localhost:8000/api';
  }

  // Helper untuk melakukan GET request dengan sistem fallback otomatis ke mock data lokal
  static Future<Map<String, dynamic>> _get(String path, Map<String, dynamic> fallbackData) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$path')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          return decoded;
        }
      }
      debugPrint('API Error on GET $path: Status ${response.statusCode}, falling back to mock.');
    } catch (e) {
      debugPrint('API Connection failed on GET $path: $e. Falling back to local mock data.');
    }
    return {'status': 'success', 'data': fallbackData};
  }

  // Helper untuk POST request
  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body, Map<String, dynamic> fallbackData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          return decoded;
        }
      }
      debugPrint('API Error on POST $path: Status ${response.statusCode}, falling back to mock.');
    } catch (e) {
      debugPrint('API Connection failed on POST $path: $e. Falling back to local mock data.');
    }
    return {
      'status': 'success',
      'message': 'Simulasi Berhasil! (Offline Fallback)',
      'data': fallbackData
    };
  }

  // 1. Dashboard API
  static Future<Map<String, dynamic>> getDashboard() async {
    final fallback = {
      'kpis': {
        'totalProjects': 4,
        'totalProjectsTrend': '+12%',
        'delayedTasks': 8,
        'delayedTasksTrend': '-2',
        'activeStaff': 42,
        'activeStaffTrend': 'LIVE',
      },
      'weeklyProductivity': [
        {
          'day': 'MON',
          'departments': [
            {'name': 'Engineering', 'value': 65},
            {'name': 'Operations', 'value': 45},
            {'name': 'Design', 'value': 80},
          ]
        },
        {
          'day': 'TUE',
          'departments': [
            {'name': 'Engineering', 'value': 85},
            {'name': 'Operations', 'value': 55},
            {'name': 'Design', 'value': 70},
          ]
        },
        {
          'day': 'WED',
          'departments': [
            {'name': 'Engineering', 'value': 95},
            {'name': 'Operations', 'value': 60},
            {'name': 'Design', 'value': 85},
          ]
        },
        {
          'day': 'THU',
          'departments': [
            {'name': 'Engineering', 'value': 45},
            {'name': 'Operations', 'value': 70},
            {'name': 'Design', 'value': 50},
          ]
        },
        {
          'day': 'FRI',
          'departments': [
            {'name': 'Engineering', 'value': 75},
            {'name': 'Operations', 'value': 90},
            {'name': 'Design', 'value': 95},
          ]
        },
      ],
      'topPerformers': [
        {
          'id': 1,
          'name': 'Sarah Chen',
          'role': 'Lead Software Engineer',
          'department': 'Engineering',
          'reliability': 98.4,
          'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDqWmAZ9YvCMMO733lcISL8wMnAyolrfiQZj6fLsbJsol-Jw0ezOu0UIK7xxUW5Dj2tRbfuYcPkRxh2ddGbYjA2BOmhfuLSgOCMaA9IaPjSUd1LwjCgUQZ3VZexLq80xSJoOEJGSWqPHDXOGz9AyR1gjxo6lUbROYkzPh9G1HOhTsPNOiV8k02UgoNKeFTsog2ctK2vkN5TmWWI3TKrtSCiHwwAHGJVn0HXhX9L0a4eGx7Tqw6ZM_8kTEa32HHYRG21yECfiSk__PKm',
        },
        {
          'id': 4,
          'name': 'David Kim',
          'role': 'Lead UI/UX Designer',
          'department': 'Design',
          'reliability': 96.8,
          'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjPYthawamKptO2svXYC5fv264uFWWqQl9In0-GIhvdJMYbhV91YV9oAn2yg7r43B96sIFx5ecN_i4KNfN2pysyEnFB3xtlQ8-fQLACG6d-HN-MC_1CZkmrqyplTuoFpHs2qIu4ZyYphrM8yyKitoUygP9PlXww_CrNTgeIqyjop4D1BP74xVjeeWioLaIC1vtzYb7yHgXD5LuDqTH00v1sHmVKNKIYYwjyZtXmz-3munyX0ZhkPP5KF1IoscqtqdI7EGTUN1IlIyy',
        },
        {
          'id': 2,
          'name': 'Marcus Wright',
          'role': 'Operations Manager',
          'department': 'Operations',
          'reliability': 91.2,
          'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXGIUJY6ngEMdJ3nstXT0GnBoR-peJFwwBvbqBfL_AYICMvxXMZfA685S2Hn6uqUHLaYmwp2xMt2k7-XEHEQFbnPQ_FCg9Kd6N1QcQq7tKPYlQaLmA_yhvpy3bu4ZA0UZTHIpcxNdW0DotC9UVbvMMhOXdQDUdFPECO_3VzAmr8v1JY5nFHNGf5n_6oTf5UNshSXZqulsCqc1raQE52dVC1t5Zoo78i9LwVSnac8_oEZUvu6PMB6piQuN9eATNxSQpYdODT8jYINzg',
        },
      ]
    };
    return _get('/dashboard', fallback);
  }

  // 2. Staff Directory API
  static Future<Map<String, dynamic>> getStaff({String? search, String? workloadStatus, String? division}) async {
    String query = '?';
    if (search != null && search.isNotEmpty) query += 'search=$search&';
    if (workloadStatus != null) query += 'workload_status=$workloadStatus&';
    if (division != null) query += 'division=$division&';

    final fallback = {
      'divisions': ['ALL', 'Engineering', 'Design', 'Operations', 'Marketing'],
      'staff': [
        {
          'id': 1,
          'name': 'Sarah Chen',
          'role': 'Lead Software Engineer',
          'department': 'Engineering',
          'workloadPercentage': 65,
          'status': 'NORMAL',
          'totalTasks': 12,
          'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDqWmAZ9YvCMMO733lcISL8wMnAyolrfiQZj6fLsbJsol-Jw0ezOu0UIK7xxUW5Dj2tRbfuYcPkRxh2ddGbYjA2BOmhfuLSgOCMaA9IaPjSUd1LwjCgUQZ3VZexLq80xSJoOEJGSWqPHDXOGz9AyR1gjxo6lUbROYkzPh9G1HOhTsPNOiV8k02UgoNKeFTsog2ctK2vkN5TmWWI3TKrtSCiHwwAHGJVn0HXhX9L0a4eGx7Tqw6ZM_8kTEa32HHYRG21yECfiSk__PKm',
        },
        {
          'id': 2,
          'name': 'Marcus Wright',
          'role': 'Operations Manager',
          'department': 'Operations',
          'workloadPercentage': 85,
          'status': 'HIGH',
          'totalTasks': 18,
          'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXGIUJY6ngEMdJ3nstXT0GnBoR-peJFwwBvbqBfL_AYICMvxXMZfA685S2Hn6uqUHLaYmwp2xMt2k7-XEHEQFbnPQ_FCg9Kd6N1QcQq7tKPYlQaLmA_yhvpy3bu4ZA0UZTHIpcxNdW0DotC9UVbvMMhOXdQDUdFPECO_3VzAmr8v1JY5nFHNGf5n_6oTf5UNshSXZqulsCqc1raQE52dVC1t5Zoo78i9LwVSnac8_oEZUvu6PMB6piQuN9eATNxSQpYdODT8jYINzg',
        },
        {
          'id': 3,
          'name': 'Elena Rodriguez',
          'role': 'Senior DevOps Specialist',
          'department': 'Engineering',
          'workloadPercentage': 92,
          'status': 'AT RISK',
          'totalTasks': 22,
          'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDrjxus22Vj_IuZzrZPIKnVoPypSi0zugFGVi4e4i43Ky8vnzeLyque-t7XnmSk29bQKn_u60Xlkqf3Hf1diSH8YmQf_y-gtkE8kYsYs-rIA2pD9uczo8LoA0wp_ExA2DTq9fuvjinorzB5UpBC4L4m3Y3U9T-Ik3EupczR2U8B32gDx4dShlAQ4GEjh40AA9GxEDhEbZ0oD7SOeqqXNWJ6D0yvw9fzAwHUNYkRrKTl0mAsm1tQ_gf8g1YD1wsv_VNvzxyT25tRpPtZ',
        },
        {
          'id': 4,
          'name': 'David Kim',
          'role': 'Lead UI/UX Designer',
          'department': 'Design',
          'workloadPercentage': 50,
          'status': 'NORMAL',
          'totalTasks': 8,
          'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjPYthawamKptO2svXYC5fv264uFWWqQl9In0-GIhvdJMYbhV91YV9oAn2yg7r43B96sIFx5ecN_i4KNfN2pysyEnFB3xtlQ8-fQLACG6d-HN-MC_1CZkmrqyplTuoFpHs2qIu4ZyYphrM8yyKitoUygP9PlXww_CrNTgeIqyjop4D1BP74xVjeeWioLaIC1vtzYb7yHgXD5LuDqTH00v1sHmVKNKIYYwjyZtXmz-3munyX0ZhkPP5KF1IoscqtqdI7EGTUN1IlIyy',
        },
      ]
    };

    // Filter manual jika connection offline
    var res = await _get('/staff$query', fallback);
    if (res['data'] == fallback) {
      List<dynamic> staffList = fallback['staff'] as List<dynamic>;
      if (search != null && search.isNotEmpty) {
        staffList = staffList.where((item) => (item['name'] as String).toLowerCase().contains(search.toLowerCase())).toList();
      }
      if (workloadStatus != null && workloadStatus != 'ALL') {
        staffList = staffList.where((item) => item['status'] == workloadStatus).toList();
      }
      if (division != null && division != 'ALL') {
        staffList = staffList.where((item) => item['department'] == division).toList();
      }
      res['data']['staff'] = staffList;
    }
    return res;
  }

  // 3. Staff Detail API
  static Future<Map<String, dynamic>> getStaffDetail(int id) async {
    final fallbacks = {
      1: {
        'id': 1,
        'name': 'Sarah Chen',
        'role': 'Lead Software Engineer',
        'department': 'Engineering',
        'workloadPercentage': 65,
        'status': 'NORMAL',
        'reliability': 98.4,
        'weeklyOutput': 24,
        'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDqWmAZ9YvCMMO733lcISL8wMnAyolrfiQZj6fLsbJsol-Jw0ezOu0UIK7xxUW5Dj2tRbfuYcPkRxh2ddGbYjA2BOmhfuLSgOCMaA9IaPjSUd1LwjCgUQZ3VZexLq80xSJoOEJGSWqPHDXOGz9AyR1gjxo6lUbROYkzPh9G1HOhTsPNOiV8k02UgoNKeFTsog2ctK2vkN5TmWWI3TKrtSCiHwwAHGJVn0HXhX9L0a4eGx7Tqw6ZM_8kTEa32HHYRG21yECfiSk__PKm',
        'activeTasks': [
          {'id': 1, 'title': 'Audit Keuangan Q3', 'description': 'Menyelesaikan audit kepatuhan pengeluaran anggaran Kominfo Triwulan 3.', 'dueDate': '30 Jun 2026', 'status': 'ACTIVE'},
          {'id': 2, 'title': 'Refactoring API Gateway', 'description': 'Optimasi rute backend untuk meningkatkan kecepatan respon server dasbor.', 'dueDate': '15 Jul 2026', 'status': 'ACTIVE'},
        ],
        'completedTasks': [
          {'id': 3, 'title': 'Integrasi Modul GPS - Stitch Tracker', 'description': 'Penyelarasan koordinat satelit ke API Flutter.', 'dueDate': '10 Mei 2026', 'status': 'COMPLETED'},
        ],
        'evaluations': [
          {'id': 1, 'note': 'Menunjukkan kinerja luar biasa dalam memimpin arsitektur clean-code.', 'date': '21 Mei 2026', 'rating': 5.0},
          {'id': 2, 'note': 'Penyelesaian integrasi modul GPS sangat rapi dan terdokumentasi dengan baik.', 'date': '12 Mei 2026', 'rating': 4.8},
        ]
      },
      2: {
        'id': 2,
        'name': 'Marcus Wright',
        'role': 'Operations Manager',
        'department': 'Operations',
        'workloadPercentage': 85,
        'status': 'HIGH',
        'reliability': 91.2,
        'weeklyOutput': 19,
        'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXGIUJY6ngEMdJ3nstXT0GnBoR-peJFwwBvbqBfL_AYICMvxXMZfA685S2Hn6uqUHLaYmwp2xMt2k7-XEHEQFbnPQ_FCg9Kd6N1QcQq7tKPYlQaLmA_yhvpy3bu4ZA0UZTHIpcxNdW0DotC9UVbvMMhOXdQDUdFPECO_3VzAmr8v1JY5nFHNGf5n_6oTf5UNshSXZqulsCqc1raQE52dVC1t5Zoo78i9LwVSnac8_oEZUvu6PMB6piQuN9eATNxSQpYdODT8jYINzg',
        'activeTasks': [
          {'id': 4, 'title': 'Evaluasi Keandalan Sistem', 'description': 'Mengevaluasi laporan kestabilan sistem cloud dan performa server PKL.', 'dueDate': '25 Jun 2026', 'status': 'ACTIVE'},
          {'id': 5, 'title': 'Rapat Koordinasi Vendor', 'description': 'Sinkronisasi tenggat waktu pengadaan perangkat keras server.', 'dueDate': '05 Jun 2026', 'status': 'ACTIVE'},
        ],
        'completedTasks': [],
        'evaluations': [
          {'id': 3, 'note': 'Beban kerja manajemen operasi mendekati kapasitas kritis, diperlukan asisten pendukung.', 'date': '18 Mei 2026', 'rating': 4.2},
        ]
      },
      3: {
        'id': 3,
        'name': 'Elena Rodriguez',
        'role': 'Senior DevOps Specialist',
        'department': 'Engineering',
        'workloadPercentage': 92,
        'status': 'AT RISK',
        'reliability': 84.7,
        'weeklyOutput': 15,
        'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDrjxus22Vj_IuZzrZPIKnVoPypSi0zugFGVi4e4i43Ky8vnzeLyque-t7XnmSk29bQKn_u60Xlkqf3Hf1diSH8YmQf_y-gtkE8kYsYs-rIA2pD9uczo8LoA0wp_ExA2DTq9fuvjinorzB5UpBC4L4m3Y3U9T-Ik3EupczR2U8B32gDx4dShlAQ4GEjh40AA9GxEDhEbZ0oD7SOeqqXNWJ6D0yvw9fzAwHUNYkRrKTl0mAsm1tQ_gf8g1YD1wsv_VNvzxyT25tRpPtZ',
        'activeTasks': [
          {'id': 6, 'title': 'Kubernetes Pod Recovery', 'description': 'Mengatasi kegagalan pod replikasi database secara berkala.', 'dueDate': '01 Jun 2026', 'status': 'ACTIVE'},
        ],
        'completedTasks': [],
        'evaluations': [
          {'id': 4, 'note': 'Keterlambatan penyelesaian pod recovery dikarenakan kendala infrastruktur AWS.', 'date': '10 Mei 2026', 'rating': 3.8},
        ]
      },
      4: {
        'id': 4,
        'name': 'David Kim',
        'role': 'Lead UI/UX Designer',
        'department': 'Design',
        'workloadPercentage': 50,
        'status': 'NORMAL',
        'reliability': 96.8,
        'weeklyOutput': 28,
        'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjPYthawamKptO2svXYC5fv264uFWWqQl9In0-GIhvdJMYbhV91YV9oAn2yg7r43B96sIFx5ecN_i4KNfN2pysyEnFB3xtlQ8-fQLACG6d-HN-MC_1CZkmrqyplTuoFpHs2qIu4ZyYphrM8yyKitoUygP9PlXww_CrNTgeIqyjop4D1BP74xVjeeWioLaIC1vtzYb7yHgXD5LuDqTH00v1sHmVKNKIYYwjyZtXmz-3munyX0ZhkPP5KF1IoscqtqdI7EGTUN1IlIyy',
        'activeTasks': [
          {'id': 7, 'title': 'Desain Layout Mobile Dashboard', 'description': 'Menyusun wireframe and UI kit bertema Slate/Navy premium.', 'dueDate': '18 Jun 2026', 'status': 'ACTIVE'},
        ],
        'completedTasks': [],
        'evaluations': []
      }
    };
    return _get('/staff/$id', fallbacks[id] ?? fallbacks[1]!);
  }

  // 4. Assign New Task
  static Future<Map<String, dynamic>> assignTask(int staffId, String title, String description, String dueDate) async {
    final body = {
      'title': title,
      'description': description,
      'dueDate': dueDate,
    };
    final mockNewTask = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'status': 'ACTIVE'
    };
    return _post('/staff/$staffId/task', body, mockNewTask);
  }

  // 5. Submit Feedback
  static Future<Map<String, dynamic>> submitFeedback(int staffId, String note, double rating) async {
    final body = {
      'note': note,
      'rating': rating,
    };
    final mockNewEval = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'note': note,
      'date': 'Hari Ini',
      'rating': rating,
    };
    return _post('/staff/$staffId/feedback', body, mockNewEval);
  }

  // 6. Projects API
  static Future<Map<String, dynamic>> getProjects({String? search}) async {
    String query = '';
    if (search != null && search.isNotEmpty) query = '?search=$search';

    final fallback = {
      'projects': [
        {
          'id': 1,
          'name': 'Stitch Location Tracker',
          'description': 'Aplikasi pemantauan koordinat GPS and log aktivitas lapangan tim operasional.',
          'targetDate': '15 Jun 2026',
          'progress': 0.85,
          'workload': 'NORMAL',
          'division': 'Engineering',
        },
        {
          'id': 2,
          'name': 'Halal Certificate Hub',
          'description': 'Sistem automasi pengajuan sertifikat halal terintegrasi kementerian.',
          'targetDate': '25 Jul 2026',
          'progress': 0.45,
          'workload': 'HIGH',
          'division': 'Engineering',
        },
        {
          'id': 3,
          'name': 'Inspektorat Dashboard',
          'description': 'Visualisasi performa and audit komprehensif berbasis Flutter mobile.',
          'targetDate': '10 Jun 2026',
          'progress': 0.95,
          'workload': 'NORMAL',
          'division': 'Design',
        },
        {
          'id': 4,
          'name': 'SAKIP Analytics',
          'description': 'Analisis data kepatuhan kinerja instansi pemerintah secara berkala.',
          'targetDate': '30 Jun 2026',
          'progress': 0.25,
          'workload': 'AT RISK',
          'division': 'Operations',
        },
      ]
    };

    var res = await _get('/projects$query', fallback);
    if (res['data'] == fallback && search != null && search.isNotEmpty) {
      List<dynamic> list = fallback['projects'] as List<dynamic>;
      list = list.where((item) {
        final name = (item['name'] as String).toLowerCase();
        final desc = (item['description'] as String).toLowerCase();
        return name.contains(search.toLowerCase()) || desc.contains(search.toLowerCase());
      }).toList();
      res['data']['projects'] = list;
    }
    return res;
  }

  // 7. Add Project API
  static Future<Map<String, dynamic>> addProject(String name, String description, String targetDate, String workload, String division, List<String> assignedStaff) async {
    final body = {
      'name': name,
      'description': description,
      'targetDate': targetDate,
      'workload': workload,
      'division': division,
      'assignedStaff': assignedStaff,
    };
    final mockNewProj = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'description': description,
      'targetDate': targetDate,
      'progress': 0.0,
      'workload': workload,
      'division': division,
      'assignedStaff': assignedStaff,
    };
    return _post('/projects', body, mockNewProj);
  }

  // 7b. Update Project API
  static Future<Map<String, dynamic>> updateProject(int id, String name, String description, String targetDate, String workload, String division, List<String> assignedStaff) async {
    final body = {
      'name': name,
      'description': description,
      'targetDate': targetDate,
      'workload': workload,
      'division': division,
      'assignedStaff': assignedStaff,
    };
    final mockUpdatedProj = {
      'id': id,
      'name': name,
      'description': description,
      'targetDate': targetDate,
      'progress': 0.5,
      'workload': workload,
      'division': division,
      'assignedStaff': assignedStaff,
    };
    return _post('/projects/$id', body, mockUpdatedProj);
  }

  // 7c. Delete Project API
  static Future<Map<String, dynamic>> deleteProject(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/projects/$id')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          return decoded;
        }
      }
      debugPrint('API Error on DELETE /projects/$id: Status ${response.statusCode}, falling back.');
    } catch (e) {
      debugPrint('API Connection failed on DELETE /projects/$id: $e. Falling back.');
    }
    return {'status': 'success', 'message': 'Simulasi Berhasil! (Offline Fallback)'};
  }

  // 8. Reports API
  static Future<Map<String, dynamic>> getReports() async {
    final fallback = {
      'metrics': {
        'globalEfficiency': '92.4%',
        'averageWorkload': '72.8%',
      },
      'reports': [
        {
          'title': 'Laporan Kinerja Instansi Pemerintah (LKIP) 2025',
          'category': 'SAKIP',
          'size': '4.2 MB',
          'date': '12 Feb 2026',
        },
        {
          'title': 'Program Kerja Pengawasan Tahunan (PKPT) 2026',
          'category': 'PKPT',
          'size': '2.8 MB',
          'date': '20 Jan 2026',
        },
        {
          'title': 'Hasil Evaluasi SAKIP Internal Kabupaten',
          'category': 'Evaluasi',
          'size': '1.5 MB',
          'date': '05 Jan 2026',
        },
        {
          'title': 'Rencana Perencanaan Kinerja Tahunan (RKT) 2026',
          'category': 'Perencanaan',
          'size': '3.1 MB',
          'date': '15 Des 2025',
        },
        {
          'title': 'Kompilasi Kebijakan & Regulasi Inspektorat',
          'category': 'Regulasi',
          'size': '5.6 MB',
          'date': '01 Des 2025',
        },
      ]
    };
    return _get('/reports', fallback);
  }

  // 9. System Notifications API
  static Future<Map<String, dynamic>> getNotifications() async {
    final fallback = {
      'notifications': [
        {
          'id': 1,
          'title': 'Sarah Chen menyelesaikan tugas Q3 Financial Audit',
          'desc': 'Audit diselesaikan dengan akurasi 98.4% dan diserahkan tepat waktu.',
          'time': '10 menit yang lalu',
          'type': 'task',
          'color': '#10B981',
          'isRead': false,
        },
        {
          'id': 2,
          'title': 'Peringatan Kapasitas Kerja: Marcus Wright',
          'desc': 'Beban kerja harian mencapai 85% dengan 7 tugas aktif. Tindakan disarankan.',
          'time': '42 menit yang lalu',
          'type': 'warning',
          'color': '#F59E0B',
          'isRead': false,
        },
        {
          'id': 3,
          'title': 'Kritikal: Elena Rodriguez (AT RISK)',
          'desc': 'Keterlambatan penyelesaian pada 3 tugas strategis. Segera hubungi divisi Ops.',
          'time': '2 jam yang lalu',
          'type': 'error',
          'color': '#EF4444',
          'isRead': false,
        },
        {
          'id': 4,
          'title': 'Dasbor Proyek: Stitch Location Tracker',
          'desc': 'Progres keseluruhan naik menjadi 85% menyusul rilis modul sinkronisasi GPS.',
          'time': '5 jam yang lalu',
          'type': 'info',
          'color': '#3B82F6',
          'isRead': false,
        },
      ]
    };
    return _get('/notifications', fallback);
  }

  // 10. Mark All Read
  static Future<Map<String, dynamic>> readAllNotifications() async {
    return _post('/notifications/read-all', {}, {});
  }

  // 11. Get User Profile API
  static Future<Map<String, dynamic>> getProfile() async {
    final fallback = {
      'name': 'Kepala',
      'email': 'executive@kominfo.go.id',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjPYthawamKptO2svXYC5fv264uFWWqQl9In0-GIhvdJMYbhV91YV9oAn2yg7r43B96sIFx5ecN_i4KNfN2pysyEnFB3xtlQ8-fQLACG6d-HN-MC_1CZkmrqyplTuoFpHs2qIu4ZyYphrM8yyKitoUygP9PlXww_CrNTgeIqyjop4D1BP74xVjeeWioLaIC1vtzYb7yHgXD5LuDqTH00v1sHmVKNKIYYwjyZtXmz-3munyX0ZhkPP5KF1IoscqtqdI7EGTUN1IlIyy',
    };
    return _get('/profile', fallback);
  }

  // 12. Update User Profile API
  static Future<Map<String, dynamic>> updateProfile(String name, String email) async {
    final body = {
      'name': name,
      'email': email,
    };
    final fallback = {
      'name': name,
      'email': email,
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjPYthawamKptO2svXYC5fv264uFWWqQl9In0-GIhvdJMYbhV91YV9oAn2yg7r43B96sIFx5ecN_i4KNfN2pysyEnFB3xtlQ8-fQLACG6d-HN-MC_1CZkmrqyplTuoFpHs2qIu4ZyYphrM8yyKitoUygP9PlXww_CrNTgeIqyjop4D1BP74xVjeeWioLaIC1vtzYb7yHgXD5LuDqTH00v1sHmVKNKIYYwjyZtXmz-3munyX0ZhkPP5KF1IoscqtqdI7EGTUN1IlIyy',
    };
    return _post('/profile', body, fallback);
  }

  // 13. Update User Avatar API
  static Future<Map<String, dynamic>> updateAvatar(String avatarUrl) async {
    final body = {
      'avatarUrl': avatarUrl,
    };
    final fallback = {
      'name': 'Kepala',
      'email': 'executive@kominfo.go.id',
      'avatarUrl': avatarUrl,
    };
    return _post('/profile/avatar', body, fallback);
  }

  // 14. Reset Password API
  static Future<Map<String, dynamic>> resetPassword(String currentPassword, String newPassword) async {
    final body = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
    return _post('/profile/reset-password', body, {});
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';

class ProjectsTab extends StatefulWidget {
  const ProjectsTab({super.key});

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  String _searchQuery = '';
  String _statusFilter = 'ALL'; // ALL, ON TRACK, AT RISK, DELAYED
  bool _isLoading = true;
  List<dynamic> _projects = [];
  List<dynamic> _allStaff = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    try {
      final response = await ApiService.getStaff();
      if (mounted && response['status'] == 'success') {
        setState(() {
          _allStaff = response['data']['staff'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Failed to load staff: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getProjects(search: _searchQuery);
      if (mounted && response['status'] == 'success') {
        setState(() {
          _projects = response['data']['projects'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load projects: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddProjectBottomSheet() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final dateController = TextEditingController();
    String selectedWorkload = 'NORMAL'; // 'NORMAL', 'HIGH', 'AT RISK'
    List<String> selectedStaff = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                        'TAMBAH PROYEK BARU',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: CorporateTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buat Inisiatif Proyek Eksekutif',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Nama Proyek
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Proyek',
                          hintText: 'Masukkan nama proyek...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi Proyek',
                          hintText: 'Deskripsikan inisiatif proyek ini...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tanggal Target
                      TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Target',
                          hintText: 'Contoh: 15 Jun 2026',
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tim Penanggung Jawab (Pilih Multipel)
                      Text(
                        'TIM PENANGGUNG JAWAB (PILIH MULTIPEL)',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _allStaff.length,
                          itemBuilder: (context, index) {
                            final staff = _allStaff[index];
                            final String name = (staff['name'] ?? staff['nama'] ?? 'Staf') as String;
                            final String role = (staff['role'] ?? staff['jabatan'] ?? 'Anggota') as String;
                            final bool isChecked = selectedStaff.contains(name);

                            return CheckboxListTile(
                              value: isChecked,
                              activeColor: CorporateTheme.success,
                              checkColor: Colors.white,
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              subtitle: Text(
                                role,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: CorporateTheme.onSurfaceVariant,
                                ),
                              ),
                              onChanged: (bool? value) {
                                setSheetState(() {
                                  if (value == true) {
                                    selectedStaff.add(name);
                                  } else {
                                    selectedStaff.remove(name);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              dense: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Estimasi Beban Kerja
                      Text(
                        'ESTIMASI BEBAN KERJA',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['NORMAL', 'HIGH', 'AT RISK'].map((workload) {
                          final bool isSelected = selectedWorkload == workload;
                          Color color = CorporateTheme.success;
                          if (workload == 'HIGH') color = CorporateTheme.warning;
                          if (workload == 'AT RISK') color = CorporateTheme.error;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                workload,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: color,
                              backgroundColor: color.withOpacity(0.1),
                              onSelected: (selected) {
                                if (selected) {
                                  setSheetState(() {
                                    selectedWorkload = workload;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isEmpty) return;

                          Navigator.pop(context);

                          // Tampilkan loading snackbar
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
                                  Text('Menyimpan proyek baru ke database...'),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          // Tentukan divisi secara otomatis berdasarkan staf pertama yang dipilih
                          String division = 'Engineering';
                          if (selectedStaff.isNotEmpty) {
                            final firstStaffName = selectedStaff.first;
                            final match = _allStaff.firstWhere(
                              (s) => (s['name'] ?? s['nama']) == firstStaffName,
                              orElse: () => null,
                            );
                            if (match != null && (match['department'] ?? match['divisi']) != null) {
                              division = (match['department'] ?? match['divisi']) as String;
                            }
                          }

                          // Simpan ke API
                          final result = await ApiService.addProject(
                            nameController.text,
                            descController.text.isNotEmpty ? descController.text : 'Tidak ada deskripsi.',
                            dateController.text.isNotEmpty ? dateController.text : 'Tenggat: Belum ditentukan',
                            selectedWorkload,
                            division,
                            selectedStaff,
                          );

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                          if (result['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text('Proyek "${nameController.text}" berhasil dibuat!'),
                                  ],
                                ),
                                backgroundColor: CorporateTheme.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            _loadProjects(); // Reload projects
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CorporateTheme.primaryContainer,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('SIMPAN PROYEK', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProjectBottomSheet(dynamic proj) {
    final nameController = TextEditingController(text: proj['name'] as String);
    final descController = TextEditingController(text: proj['description'] as String);
    final dateController = TextEditingController(text: proj['targetDate'] as String);
    String selectedWorkload = proj['workload'] as String;
    List<String> selectedStaff = List<String>.from(proj['assignedStaff'] ?? []);
    final int projId = proj['id'] as int;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                        'EDIT DETAIL PROYEK',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: CorporateTheme.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nama Proyek
                      Text(
                        'NAMA PROYEK',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama inisiatif...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      Text(
                        'DESKRIPSI PROYEK',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Tuliskan deskripsi ringkas...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Target Tenggat Waktu
                      Text(
                        'BEBAN TARGET SELESAI (DEADLINE)',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: 15 Jun 2026 atau 30 Jun 2026',
                          prefixIcon: const Icon(Icons.calendar_today, size: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tim Penanggung Jawab (Pilih Multipel)
                      Text(
                        'TIM PENANGGUNG JAWAB (PILIH MULTIPEL)',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _allStaff.length,
                          itemBuilder: (context, index) {
                            final staff = _allStaff[index];
                            final String name = (staff['name'] ?? staff['nama'] ?? 'Staf') as String;
                            final String role = (staff['role'] ?? staff['jabatan'] ?? 'Anggota') as String;
                            final bool isChecked = selectedStaff.contains(name);

                            return CheckboxListTile(
                              value: isChecked,
                              activeColor: CorporateTheme.success,
                              checkColor: Colors.white,
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              subtitle: Text(
                                role,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: CorporateTheme.onSurfaceVariant,
                                ),
                              ),
                              onChanged: (bool? value) {
                                setSheetState(() {
                                  if (value == true) {
                                    selectedStaff.add(name);
                                  } else {
                                    selectedStaff.remove(name);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              dense: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Estimasi Beban Kerja
                      Text(
                        'ESTIMASI BEBAN KERJA',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['NORMAL', 'HIGH', 'AT RISK'].map((workload) {
                          final bool isSelected = selectedWorkload == workload;
                          Color color = CorporateTheme.success;
                          if (workload == 'HIGH') color = CorporateTheme.warning;
                          if (workload == 'AT RISK') color = CorporateTheme.error;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                workload,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: color,
                              backgroundColor: color.withOpacity(0.1),
                              onSelected: (selected) {
                                if (selected) {
                                  setSheetState(() {
                                    selectedWorkload = workload;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Hapus Proyek', style: TextStyle(fontWeight: FontWeight.bold)),
                                    content: Text('Apakah Anda yakin ingin menghapus inisiatif proyek "${proj['name']}"? Tindakan ini tidak dapat dibatalkan.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('BATAL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('HAPUS', style: TextStyle(color: CorporateTheme.error, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  if (!context.mounted) return;
                                  Navigator.pop(context); // Close bottom sheet

                                  // Tampilkan loading snackbar
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
                                          Text('Menghapus proyek dari database...'),
                                        ],
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );

                                  // Panggil API Hapus
                                  final result = await ApiService.deleteProject(projId);

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                  if (result['status'] == 'success') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.delete_forever, color: Colors.white),
                                            const SizedBox(width: 8),
                                            Text('Proyek "${proj['name']}" berhasil dihapus.'),
                                          ],
                                        ),
                                        backgroundColor: CorporateTheme.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    _loadProjects(); // Reload projects
                                  }
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: CorporateTheme.error,
                                side: const BorderSide(color: CorporateTheme.error, width: 1.5),
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('HAPUS', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (nameController.text.isEmpty) return;

                                Navigator.pop(context);

                                // Tampilkan loading snackbar
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
                                        Text('Memperbarui proyek di database...'),
                                      ],
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                // Tentukan divisi secara otomatis berdasarkan staf pertama yang dipilih
                                String division = 'Engineering';
                                if (selectedStaff.isNotEmpty) {
                                  final firstStaffName = selectedStaff.first;
                                  final match = _allStaff.firstWhere(
                                    (s) => (s['name'] ?? s['nama']) == firstStaffName,
                                    orElse: () => null,
                                  );
                                  if (match != null && (match['department'] ?? match['divisi']) != null) {
                                    division = (match['department'] ?? match['divisi']) as String;
                                  }
                                }

                                // Perbarui di API
                                final result = await ApiService.updateProject(
                                  projId,
                                  nameController.text,
                                  descController.text.isNotEmpty ? descController.text : 'Tidak ada deskripsi.',
                                  dateController.text.isNotEmpty ? dateController.text : 'Tenggat: Belum ditentukan',
                                  selectedWorkload,
                                  division,
                                  selectedStaff,
                                );

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                                if (result['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_outline, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text('Proyek "${nameController.text}" berhasil diperbarui!'),
                                        ],
                                      ),
                                      backgroundColor: CorporateTheme.success,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  _loadProjects(); // Reload projects
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CorporateTheme.primaryContainer,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.bold)),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Filter projects locally
    List<dynamic> filteredProjects = _projects;
    if (_statusFilter != 'ALL') {
      filteredProjects = filteredProjects.where((p) => p['workload'] == _statusFilter).toList();
    }

    return Scaffold(
      backgroundColor: CorporateTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProjects,
          color: CorporateTheme.primary,
          child: Column(
            children: [
              // Header & Search
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MONITORING PROYEK',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: CorporateTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inisiatif Strategis',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        FloatingActionButton.small(
                          onPressed: _showAddProjectBottomSheet,
                          backgroundColor: CorporateTheme.primaryContainer,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                        _loadProjects(); // Reload projects on search
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari proyek...',
                        prefixIcon: const Icon(Icons.search, color: CorporateTheme.outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: CorporateTheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: CorporateTheme.background,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: ['ALL', 'NORMAL', 'HIGH', 'AT RISK'].map((filter) {
                          final bool isSelected = _statusFilter == filter;
                          Color chipColor = CorporateTheme.primary;
                          if (filter == 'NORMAL') chipColor = CorporateTheme.success;
                          if (filter == 'HIGH') chipColor = CorporateTheme.warning;
                          if (filter == 'AT RISK') chipColor = CorporateTheme.error;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                filter,
                                style: textTheme.labelLarge?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : chipColor,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: chipColor,
                              backgroundColor: chipColor.withOpacity(0.08),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _statusFilter = filter;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Projects List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
                        ),
                      )
                    : filteredProjects.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada proyek yang sesuai.',
                              style: TextStyle(fontSize: 13, color: CorporateTheme.onSurfaceVariant),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20.0),
                            itemCount: filteredProjects.length,
                            itemBuilder: (context, index) {
                              final proj = filteredProjects[index];
                              final double progress = (proj['progress'] as num).toDouble();
                              final String workload = proj['workload'] as String;

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
                                margin: const EdgeInsets.only(bottom: 16.0),
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
                                              (proj['division'] as String).toUpperCase(),
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
                                              color: workloadBg,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              workload,
                                              style: textTheme.labelLarge?.copyWith(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: workloadColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        proj['name'] as String,
                                        style: textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
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
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (proj['assignedStaff'] != null && (proj['assignedStaff'] as List).isNotEmpty) ...[
                                        Text(
                                          'TIM PENANGGUNG JAWAB',
                                          style: textTheme.labelLarge?.copyWith(
                                            fontSize: 9,
                                            color: CorporateTheme.onSurfaceVariant,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: (proj['assignedStaff'] as List<dynamic>).map((staffName) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                              ),
                                              child: Text(
                                                staffName as String,
                                                style: textTheme.labelLarge?.copyWith(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF1E293B),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
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
                                              fontWeight: FontWeight.bold,
                                              color: CorporateTheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(9999),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6,
                                          backgroundColor: const Color(0xFFF1F5F9),
                                          valueColor: AlwaysStoppedAnimation<Color>(workloadColor),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today_outlined, size: 12, color: CorporateTheme.outline),
                                              const SizedBox(width: 4),
                                              Text(
                                                proj['targetDate'] as String,
                                                style: textTheme.labelLarge?.copyWith(
                                                  fontSize: 10,
                                                  color: CorporateTheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () => _showEditProjectBottomSheet(proj),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.edit, size: 12, color: CorporateTheme.primary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'EDIT',
                                                  style: textTheme.labelLarge?.copyWith(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: CorporateTheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

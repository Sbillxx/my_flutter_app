import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'staff_detail_screen.dart';
import '../widgets/notification_sheet.dart';
import '../services/api_service.dart';

class StaffDirectoryTab extends StatefulWidget {
  const StaffDirectoryTab({super.key});

  @override
  State<StaffDirectoryTab> createState() => _StaffDirectoryTabState();
}

class _StaffDirectoryTabState extends State<StaffDirectoryTab> {
  String _selectedCategory = 'All Teams';
  String _searchQuery = '';
  String _statusFilter = 'ALL'; // ALL, NORMAL, HIGH, AT RISK
  bool _isLoading = true;
  List<dynamic> _staff = [];
  List<dynamic> _divisions = ['ALL'];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? divisionParam = _selectedCategory == 'All Teams' ? null : _selectedCategory;
      final String? statusParam = _statusFilter == 'ALL' ? null : _statusFilter;
      final response = await ApiService.getStaff(
        search: _searchQuery,
        workloadStatus: statusParam,
        division: divisionParam,
      );

      if (mounted && response['status'] == 'success') {
        setState(() {
          _staff = response['data']['staff'] ?? [];
          final rawDivs = response['data']['divisions'] as List<dynamic>?;
          if (rawDivs != null) {
            _divisions = rawDivs.map((d) => d == 'ALL' ? 'All Teams' : d.toString()).toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load staff: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FILTER KAPASITAS KERJA',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: CorporateTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              ...['ALL', 'NORMAL', 'HIGH', 'AT RISK'].map((status) {
                final bool isSelected = _statusFilter == status;
                Color color = CorporateTheme.primary;
                if (status == 'NORMAL') color = CorporateTheme.success;
                if (status == 'HIGH') color = CorporateTheme.warning;
                if (status == 'AT RISK') color = CorporateTheme.error;

                return ListTile(
                  title: Text(
                    status,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: color,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check, color: color) : null,
                  onTap: () {
                    setState(() {
                      _statusFilter = status;
                    });
                    _loadStaff(); // Reload staff
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CorporateTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStaff,
          color: CorporateTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top AppBar (Custom)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DIREKTORI TIM',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: CorporateTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Divisi & Anggota',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.tune,
                            color: CorporateTheme.primary,
                          ),
                          onPressed: _showFilterBottomSheet,
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
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Metrik Tonal Grid (2x2)
                _isLoading
                    ? const SizedBox(
                        height: 140,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
                          ),
                        ),
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.1,
                        children: [
                          _buildGridMetricCard(
                            label: 'NORMAL WORKLOAD',
                            value: _staff.where((s) => s['status'] == 'NORMAL').length.toString(),
                            color: CorporateTheme.success,
                          ),
                          _buildGridMetricCard(
                            label: 'HIGH CAPACITY',
                            value: _staff.where((s) => s['status'] == 'HIGH').length.toString(),
                            color: CorporateTheme.warning,
                          ),
                          _buildGridMetricCard(
                            label: 'AT RISK MEMBERS',
                            value: _staff.where((s) => s['status'] == 'AT RISK').length.toString(),
                            color: CorporateTheme.error,
                          ),
                          _buildGridMetricCard(
                            label: 'TOTAL MEMBERS',
                            value: _staff.length.toString(),
                            color: CorporateTheme.primary,
                          ),
                        ],
                      ),
                const SizedBox(height: 16),

                // 3. Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                    _loadStaff(); // Reload staff
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari staf...',
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
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Kategori Filter (Chips)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _divisions.map((category) {
                      final bool isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            category,
                            style: textTheme.labelLarge?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : CorporateTheme.onSurfaceVariant,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: CorporateTheme.primaryContainer,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                              _loadStaff(); // Reload staff on category change
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Staff Card List
                _isLoading
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary),
                          ),
                        ),
                      )
                    : _staff.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'Tidak ada staf yang sesuai.',
                                style: TextStyle(fontSize: 13, color: CorporateTheme.onSurfaceVariant),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _staff.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final staff = _staff[index];
                              final String status = staff['status'] as String;
                              final int workloadPercentage = (staff['workloadPercentage'] as num).toInt();

                              Color statusColor = CorporateTheme.success;
                              Color statusBg = CorporateTheme.success.withOpacity(0.1);
                              if (status == 'HIGH') {
                                statusColor = CorporateTheme.warning;
                                statusBg = CorporateTheme.warning.withOpacity(0.1);
                              } else if (status == 'AT RISK') {
                                statusColor = CorporateTheme.error;
                                statusBg = CorporateTheme.error.withOpacity(0.1);
                              }

                              return Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
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
                                          ).then((_) => _loadStaff());
                                        },
                                        leading: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: CorporateTheme.background,
                                          backgroundImage: NetworkImage(staff['avatarUrl'] as String),
                                        ),
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              staff['name'] as String,
                                              style: textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: statusBg,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                status,
                                                style: textTheme.labelLarge?.copyWith(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(
                                          '${staff['role']} • ${staff['department']}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontSize: 12,
                                            color: CorporateTheme.onSurfaceVariant,
                                          ),
                                        ),
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
                                            '$workloadPercentage%',
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
                                          value: workloadPercentage / 100,
                                          minHeight: 6,
                                          backgroundColor: const Color(0xFFF1F5F9),
                                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridMetricCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

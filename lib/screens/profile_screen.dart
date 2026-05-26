import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'account_security_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Stateful switches for settings preferences
  bool _pushNotifications = true;
  bool _isLoading = true;

  // Personal Info (loaded dynamically from database)
  String _displayName = 'Kepala Bidang';
  String _emailAddress = 'kepala.ops@kominfo.go.id';
  String _avatarUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjPYthawamKptO2svXYC5fv264uFWWqQl9In0-GIhvdJMYbhV91YV9oAn2yg7r43B96sIFx5ecN_i4KNfN2pysyEnFB3xtlQ8-fQLACG6d-HN-MC_1CZkmrqyplTuoFpHs2qIu4ZyYphrM8yyKitoUygP9PlXww_CrNTgeIqyjop4D1BP74xVjeeWioLaIC1vtzYb7yHgXD5LuDqTH00v1sHmVKNKIYYwjyZtXmz-3munyX0ZhkPP5KF1IoscqtqdI7EGTUN1IlIyy';

  // 6 Curated Kementerian/Premium Avatars
  final List<String> _curatedAvatars = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDjPYthawamKptO2svXYC5fv264uFWWqQl9In0-GIhvdJMYbhV91YV9oAn2yg7r43B96sIFx5ecN_i4KNfN2pysyEnFB3xtlQ8-fQLACG6d-HN-MC_1CZkmrqyplTuoFpHs2qIu4ZyYphrM8yyKitoUygP9PlXww_CrNTgeIqyjop4D1BP74xVjeeWioLaIC1vtzYb7yHgXD5LuDqTH00v1sHmVKNKIYYwjyZtXmz-3munyX0ZhkPP5KF1IoscqtqdI7EGTUN1IlIyy',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDqWmAZ9YvCMMO733lcISL8wMnAyolrfiQZj6fLsbJsol-Jw0ezOu0UIK7xxUW5Dj2tRbfuYcPkRxh2ddGbYjA2BOmhfuLSgOCMaA9IaPjSUd1LwjCgUQZ3VZexLq80xSJoOEJGSWqPHDXOGz9AyR1gjxo6lUbROYkzPh9G1HOhTsPNOiV8k02UgoNKeFTsog2ctK2vkN5TmWWI3TKrtSCiHwwAHGJVn0HXhX9L0a4eGx7Tqw6ZM_8kTEa32HHYRG21yECfiSk__PKm',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAXGIUJY6ngEMdJ3nstXT0GnBoR-peJFwwBvbqBfL_AYICMvxXMZfA685S2Hn6uqUHLaYmwp2xMt2k7-XEHEQFbnPQ_FCg9Kd6N1QcQq7tKPYlQaLmA_yhvpy3bu4ZA0UZTHIpcxNdW0DotC9UVbvMMhOXdQDUdFPECO_3VzAmr8v1JY5nFHNGf5n_6oTf5UNshSXZqulsCqc1raQE52dVC1t5Zoo78i9LwVSnac8_oEZUvu6PMB6piQuN9eATNxSQpYdODT8jYINzg',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDrjxus22Vj_IuZzrZPIKnVoPypSi0zugFGVi4e4i43Ky8vnzeLyque-t7XnmSk29bQKn_u60Xlkqf3Hf1diSH8YmQf_y-gtkE8kYsYs-rIA2pD9uczo8LoA0wp_ExA2DTq9fuvjinorzB5UpBC4L4m3Y3U9T-Ik3EupczR2U8B32gDx4dShlAQ4GEjh40AA9GxEDhEbZ0oD7SOeqqXNWJ6D0yvw9fzAwHUNYkRrKTl0mAsm1tQ_gf8g1YD1wsv_VNvzxyT25tRpPtZ',
    'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80'
  ];

  @override
  void initState() {
    super.initState();
    _pushNotifications = NotificationService.isEnabled;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final res = await ApiService.getProfile();
      if (mounted && res['status'] == 'success') {
        final data = res['data'];
        setState(() {
          _displayName = data['name'] ?? 'Kepala Bidang';
          _emailAddress = data['email'] ?? 'kepala.ops@kominfo.go.id';
          _avatarUrl = data['avatarUrl'] ?? _avatarUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load profile data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _displayName);
    final emailController = TextEditingController(text: _emailAddress);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'EDIT DETAIL PROFIL',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: CorporateTheme.primaryContainer,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  labelStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                  labelStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BATAL', style: TextStyle(color: CorporateTheme.outline)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                  // Capture Navigator and ScaffoldMessenger states before the async gap
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final res = await ApiService.updateProfile(nameController.text, emailController.text);
                    navigator.pop(); // Pop loading spinner
                    if (res['status'] == 'success') {
                      setState(() {
                        _displayName = nameController.text;
                        _emailAddress = emailController.text;
                      });
                      navigator.pop(); // Pop edit dialog
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: CorporateTheme.success,
                        ),
                      );
                    } else {
                      navigator.pop();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Gagal memperbarui: ${res['message']}')),
                      );
                    }
                  } catch (e) {
                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Gagal terhubung ke API: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CorporateTheme.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('SIMPAN'),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarPickerDialog() {
    final customUrlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'CRUD GAMBAR PROFIL',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: CorporateTheme.primaryContainer,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih salah satu avatar premium di bawah ini atau masukkan tautan kustom Anda.',
                style: TextStyle(fontSize: 11, color: CorporateTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickImageFromFileManager,
                icon: const Icon(Icons.photo_library_rounded, size: 16, color: CorporateTheme.primaryContainer),
                label: Text(
                  'AMBIL DARI FILE MANAGER',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: CorporateTheme.primaryContainer),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: CorporateTheme.primaryContainer),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(double.infinity, 38),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.maxFinite,
                height: 130,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _curatedAvatars.length,
                  itemBuilder: (context, index) {
                    final url = _curatedAvatars[index];
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context); // Close dialog
                        await _updateAvatarImage(url);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _avatarUrl == url ? CorporateTheme.primary : Colors.transparent,
                            width: 3,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: customUrlController,
                decoration: InputDecoration(
                  labelText: 'Tautan Gambar Kustom (URL)',
                  labelStyle: const TextStyle(fontSize: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BATAL', style: TextStyle(color: CorporateTheme.outline)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (customUrlController.text.isNotEmpty) {
                  Navigator.pop(context);
                  await _updateAvatarImage(customUrlController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CorporateTheme.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('SIMPAN'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAvatarImage(String url) async {
    // Capture Navigator and ScaffoldMessenger states before the async gap
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await ApiService.updateAvatar(url);
      navigator.pop(); // pop loading spinner
      if (res['status'] == 'success') {
        setState(() {
          _avatarUrl = url;
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: CorporateTheme.success,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Gagal memperbarui avatar: ${res['message']}')),
        );
      }
    } catch (e) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Gagal terhubung ke API: $e')),
      );
    }
  }

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

  Future<void> _pickImageFromFileManager() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Compress to avoid massive base64 strings
        maxWidth: 400,    // Resize to keep database size optimal
        maxHeight: 400,
      );

      if (image != null) {
        // Read file bytes
        final bytes = await image.readAsBytes();
        // Convert to Base64 string
        final String base64Image = base64Encode(bytes);
        // Prefix with data URI pattern so we know it's a base64 image
        final String base64Url = 'data:image/png;base64,$base64Image';

        // Close the avatar picker dialog first
        if (mounted) {
          Navigator.pop(context);
        }

        // Update via API
        await _updateAvatarImage(base64Url);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: CorporateTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showHelpCenterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CorporateTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.help_outline_rounded, color: CorporateTheme.primaryContainer, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Pusat Bantuan & FAQ',
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFAQItem(
                  'Bagaimana cara mendelegasikan tugas baru?',
                  'Masuk ke tab "Direktori Karyawan" di navigasi bawah, ketuk nama staf yang ingin ditugaskan, lalu ketuk tombol "ASSIGN NEW TASK" di bawah detail performa staf tersebut.',
                ),
                const Divider(),
                _buildFAQItem(
                  'Bagaimana cara memantau kapasitas beban kerja staf?',
                  'Warna status di samping nama staf menunjukkan risiko beban kerja. NORMAL (Hijau) berarti kapasitas aman, HIGH (Amber) berarti kapasitas padat, dan AT RISK (Merah) berarti melebihi kapasitas dan rentan mengalami keterlambatan.',
                ),
                const Divider(),
                _buildFAQItem(
                  'Mengapa data tidak tersinkronisasi?',
                  'Pastikan server backend Laravel Anda aktif di port 8000. Jika server offline, aplikasi akan menggunakan sistem fallback pintar yang menampilkan data simulasi agar UI tidak putih.',
                ),
                const Divider(),
                _buildFAQItem(
                  'Bagaimana cara mengubah info & foto profil?',
                  'Di halaman profil Anda, ketuk tombol edit pada lingkaran foto profil untuk mengubah gambar, atau ketuk opsi "Edit Detail Profil" untuk memperbarui nama dan email.',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CorporateTheme.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('MENGERTI', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CorporateTheme.primary),
        ),
        iconColor: CorporateTheme.primary,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 11, color: CorporateTheme.onSurfaceVariant, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CorporateTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.logout_rounded, color: CorporateTheme.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'KONFIRMASI KELUAR',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: CorporateTheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin keluar dari Dasbor Kinerja Eksekutif?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CorporateTheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: CorporateTheme.outlineVariant),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('BATAL', style: TextStyle(color: CorporateTheme.primaryContainer, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close sheet
                        Navigator.pop(context); // Pop profile screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Berhasil keluar dari akun.'),
                            backgroundColor: CorporateTheme.primaryContainer,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CorporateTheme.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('YA, KELUAR', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'PROFIL PENGGUNA',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: CorporateTheme.primary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: CorporateTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CorporateTheme.primary)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 1. User Header Banner Container
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: CorporateTheme.primary, width: 3),
                                image: DecorationImage(
                                  image: _getImageProvider(_avatarUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showAvatarPickerDialog,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: CorporateTheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _displayName,
                          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _emailAddress,
                          style: textTheme.bodyMedium?.copyWith(color: CorporateTheme.outline),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: CorporateTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: CorporateTheme.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'STATUS: AKTIF • KOMINFO',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: CorporateTheme.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Glassmorphic Division Stats Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INFORMASI KEPEMIMPINAN',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: CorporateTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatItem('DIVISI', 'Operations', Icons.domain_rounded),
                              Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                              _buildStatItem('AKSES', 'Super Admin', Icons.admin_panel_settings_rounded),
                              Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                              _buildStatItem('LISENSI', 'Enterprise', Icons.verified_rounded),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Settings Groups
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Detail Profil',
                            subtitle: 'Ubah nama lengkap dan email Anda',
                            onTap: _showEditProfileDialog,
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildSettingsSwitchTile(
                            icon: Icons.notifications_none_outlined,
                            title: 'Notifikasi Dasbor',
                            subtitle: 'Terima push alert pemantauan tim',
                            value: _pushNotifications,
                            onChanged: (val) {
                              setState(() {
                                _pushNotifications = val;
                                NotificationService.isEnabled = val;
                              });
                            },
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildSettingsTile(
                            icon: Icons.shield_outlined,
                            title: 'Keamanan Akun',
                            subtitle: 'Konfigurasi kata sandi & enkripsi',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AccountSecurityScreen(),
                                ),
                              ).then((_) {
                                // Reload profile just in case password reset affects things or for visual sync
                                _loadProfileData();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Support Group
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Pusat Bantuan & FAQ',
                            subtitle: 'Petunjuk lengkap sistem dasbor',
                            onTap: _showHelpCenterBottomSheet,
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildSettingsTile(
                            icon: Icons.info_outline_rounded,
                            title: 'Tentang Aplikasi',
                            subtitle: 'Executive Command Dashboard v1.0.0',
                            onTap: () {
                              showAboutDialog(
                                context: context,
                                applicationName: 'Executive Command Dashboard',
                                applicationVersion: '1.0.0',
                                applicationLegalese: '© 2026 PKL Kominfo Team',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Red Logout Action Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: _showLogoutConfirmBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CorporateTheme.errorContainer.withOpacity(0.2),
                        foregroundColor: CorporateTheme.error,
                        elevation: 0,
                        side: const BorderSide(color: CorporateTheme.errorContainer),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'KELUAR DARI AKUN',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: CorporateTheme.primaryContainer),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: CorporateTheme.outline),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: CorporateTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CorporateTheme.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: CorporateTheme.primaryContainer),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CorporateTheme.primary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: CorporateTheme.outline)),
      trailing: const Icon(Icons.chevron_right_rounded, color: CorporateTheme.outline),
      onTap: onTap,
    );
  }

  Widget _buildSettingsSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CorporateTheme.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: CorporateTheme.primaryContainer),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CorporateTheme.primary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: CorporateTheme.outline)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: CorporateTheme.primary,
      ),
    );
  }
}

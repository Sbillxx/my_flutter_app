import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final res = await ApiService.resetPassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        if (res['status'] == 'success') {
          // Show Success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                icon: const Icon(Icons.check_circle_outline_rounded, color: CorporateTheme.success, size: 54),
                title: Text(
                  'KATA SANDI DIPERBARUI',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: CorporateTheme.success,
                  ),
                ),
                content: const Text(
                  'Kata sandi akun eksekutif Anda berhasil diamankan dan diperbarui ke database.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Pop dialog
                        Navigator.pop(context); // Pop security screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CorporateTheme.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('OK'),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          // Show error message
          final msg = res['message'] ?? 'Gagal memperbarui kata sandi.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: CorporateTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Koneksi gagal: $e'),
            backgroundColor: CorporateTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CorporateTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'KEAMANAN AKUN',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium banner card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CorporateTheme.primary, CorporateTheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CorporateTheme.primary.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(Icons.security_rounded, color: Colors.white, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enkripsi Data Aman',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Semua kata sandi dienkripsi dengan algoritma bcrypt tingkat lanjut di database MySQL.',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'RESET KATA SANDI',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: CorporateTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Form
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Current Password
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Saat Ini',
                          labelStyle: const TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.lock_open_rounded, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrent ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 13),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi saat ini wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // New Password
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Baru',
                          labelStyle: const TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 13),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi baru wajib diisi';
                          }
                          if (value.length < 8) {
                            return 'Kata sandi baru minimal harus 8 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Kata Sandi Baru',
                          labelStyle: const TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.lock_rounded, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 13),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi kata sandi baru wajib diisi';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Konfirmasi kata sandi tidak cocok dengan kata sandi baru';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitResetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CorporateTheme.primaryContainer,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: CorporateTheme.primaryContainer.withOpacity(0.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'PERBARUI KATA SANDI',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

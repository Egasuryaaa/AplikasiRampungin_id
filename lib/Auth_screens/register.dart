import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/auth_service.dart';
import 'package:rampungin_id_userside/models/register_request.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final noHpController = TextEditingController();
  final alamatController = TextEditingController();
  final pengalamanController = TextEditingController(text: '0');
  final tarifController = TextEditingController(text: '0');
  final bioController = TextEditingController();
  final passwordController = TextEditingController();
  final konfirmasiPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final kotaController = TextEditingController();
  final provinsiController = TextEditingController();
  final kodePosController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _jenisAkun = 'client';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    if (!mounted) return;
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    namaController.dispose();
    emailController.dispose();
    noHpController.dispose();
    alamatController.dispose();
    pengalamanController.dispose();
    tarifController.dispose();
    bioController.dispose();
    passwordController.dispose();
    konfirmasiPasswordController.dispose();
    usernameController.dispose();
    kotaController.dispose();
    provinsiController.dispose();
    kodePosController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != konfirmasiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password dan konfirmasi tidak sama."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create request object
      final request = RegisterRequest(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        namaLengkap: namaController.text.trim(),
        noTelp: noHpController.text.trim(),
        role: _jenisAkun,
        fotoProfil: null,
        alamat:
            alamatController.text.trim().isEmpty
                ? null
                : alamatController.text.trim(),
        kota:
            kotaController.text.trim().isEmpty
                ? null
                : kotaController.text.trim(),
        provinsi:
            provinsiController.text.trim().isEmpty
                ? null
                : provinsiController.text.trim(),
        kodePos:
            kodePosController.text.trim().isEmpty
                ? null
                : kodePosController.text.trim(),
        // Tukang-specific fields
        pengalamanTahun:
            _jenisAkun == 'tukang'
                ? int.tryParse(pengalamanController.text)
                : null,
        tarifPerJam:
            _jenisAkun == 'tukang'
                ? int.tryParse(tarifController.text)?.toDouble()
                : null,
        bio:
            _jenisAkun == 'tukang' && bioController.text.trim().isNotEmpty
                ? bioController.text.trim()
                : null,
        keahlian: null,
        kategoriIds: null,
        namaBank: null,
        nomorRekening: null,
        namaPemilikRekening: null,
      );

      final response = await _authService.register(request);

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        // Check if user is auto-verified (Client) or needs verification (Tukang)
        if (response.data!.isVerified) {
          // Client - auto-verified, can login immediately
          _showSuccessDialog(
            title: 'Registrasi Berhasil!',
            content:
                'Akun client Anda telah dibuat dan diverifikasi.\n\n'
                'Anda dapat langsung login sekarang.',
            isVerified: true,
          );
        } else {
          // Tukang - needs admin verification
          _showSuccessDialog(
            title: 'Registrasi Berhasil!',
            content:
                'Akun tukang Anda telah dibuat!\n\n'
                '⚠️ Akun Anda perlu diverifikasi oleh Admin terlebih dahulu '
                'sebelum dapat login.\n\n'
                'Proses verifikasi biasanya memakan waktu 1-2 hari kerja. '
                'Mohon tunggu konfirmasi dari Admin.',
            isVerified: false,
          );
        }
      } else {
        // Error from server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog({
    required String title,
    required String content,
    required bool isVerified,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            icon: Icon(
              isVerified ? Icons.check_circle : Icons.access_time,
              color: isVerified ? Colors.green : Colors.orange,
              size: 50,
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(content, textAlign: TextAlign.center),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to login
                },
                child: Text(isVerified ? 'Login Sekarang' : 'OK, Mengerti'),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE8A63C)),
        suffixIcon:
            toggleObscure != null
                ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFE8A63C),
                  ),
                  onPressed: toggleObscure,
                )
                : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3B950),
        title: const Text(
          "Daftar Akun",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  Image.asset(
                    'assets/img/LogoRampung.png',
                    width: 100,
                    height: 100,
                    errorBuilder:
                        (context, error, stack) => const Icon(Icons.image),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Buat Akun Baru",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    label: "Nama Lengkap",
                    icon: Icons.person_outline,
                    controller: namaController,
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? "Nama tidak boleh kosong"
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Email",
                    icon: Icons.email_outlined,
                    controller: emailController,
                    validator:
                        (v) =>
                            v == null || !v.contains('@')
                                ? "Email tidak valid"
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Username",
                    icon: Icons.account_circle_outlined,
                    controller: usernameController,
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? "Username wajib diisi"
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Kota",
                    icon: Icons.location_city,
                    controller: kotaController,
                    // Made optional - no validator
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    label: "Provinsi",
                    icon: Icons.map_outlined,
                    controller: provinsiController,
                    // Made optional - no validator
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    label: "Kode Pos",
                    icon: Icons.markunread_mailbox_outlined,
                    controller: kodePosController,
                    // Made optional - only validate format if not empty
                    validator: (v) {
                      if (v != null &&
                          v.isNotEmpty &&
                          int.tryParse(v) == null) {
                        return "Kode pos harus berupa angka";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "No. HP",
                    icon: Icons.phone_android,
                    controller: noHpController,
                    validator:
                        (v) =>
                            v == null || v.isEmpty ? "No HP wajib diisi" : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Alamat",
                    icon: Icons.home_outlined,
                    controller: alamatController,
                    // Made optional - no validator
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _jenisAkun,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Jenis Akun",
                      prefixIcon: const Icon(
                        Icons.badge,
                        color: Color(0xFFE8A63C),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'client', child: Text('Client')),
                      DropdownMenuItem(value: 'tukang', child: Text('Tukang')),
                    ],
                    onChanged:
                        (String? v) =>
                            setState(() => _jenisAkun = v ?? 'client'),
                  ),

                  const SizedBox(height: 20),
                  if (_jenisAkun == 'tukang') ...[
                    _buildTextField(
                      label: "Pengalaman (tahun)",
                      icon: Icons.work_outline,
                      controller: pengalamanController,
                      validator: (v) {
                        if (v != null &&
                            v.isNotEmpty &&
                            int.tryParse(v) == null) {
                          return "Harus berupa angka";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: "Tarif per Jam (Rp)",
                      icon: Icons.payments_outlined,
                      controller: tarifController,
                      validator: (v) {
                        if (v != null &&
                            v.isNotEmpty &&
                            int.tryParse(v) == null) {
                          return "Harus berupa angka";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: "Bio",
                      icon: Icons.description_outlined,
                      controller: bioController,
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildTextField(
                    label: "Password",
                    icon: Icons.lock_outline,
                    controller: passwordController,
                    obscure: _obscurePassword,
                    toggleObscure: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    validator:
                        (v) =>
                            v == null || v.length < 6
                                ? "Minimal 6 karakter"
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Konfirmasi Password",
                    icon: Icons.lock_reset,
                    controller: konfirmasiPasswordController,
                    obscure: _obscureConfirm,
                    toggleObscure: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                    validator:
                        (v) =>
                            v == null || v.isEmpty ? "Ulangi password" : null,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8A63C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                              : const Text(
                                "DAFTAR",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Sudah punya akun? Login di sini",
                      style: TextStyle(
                        color: Color(0xFFE8A63C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

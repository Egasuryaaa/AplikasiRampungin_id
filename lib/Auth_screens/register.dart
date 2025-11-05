import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/auth_service.dart';

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
  final keahlianController = TextEditingController();
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
    keahlianController.dispose();
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
      Map<String, dynamic> registrationData = {
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'namaLengkap': namaController.text.trim(),
        'noTelp': noHpController.text.trim(),
        'role': _jenisAkun,
        'alamat': alamatController.text.trim(),
        'kota': kotaController.text.trim(),
        'provinsi': provinsiController.text.trim(),
        'kodePos': kodePosController.text.trim(),
      };

      if (_jenisAkun == "tukang") {
        registrationData.addAll({
          'pengalaman_tahun': int.tryParse(pengalamanController.text) ?? 0,
          'tarif_per_jam': int.tryParse(tarifController.text) ?? 0,
          'bio': bioController.text.trim(),
          'keahlian':
              keahlianController.text.split(',').map((e) => e.trim()).toList(),
          'kategori_ids': "[]",
          'nama_bank': "",
          'nomor_rekening': "",
          'nama_pemilik_rekening': "",
        });
      }

      final response = await _authService.register(registrationData);

      if (!mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Silakan login."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi gagal!"),
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
                    validator:
                        (v) =>
                            v == null || v.isEmpty ? "Kota wajib diisi" : null,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    label: "Provinsi",
                    icon: Icons.map_outlined,
                    controller: provinsiController,
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? "Provinsi wajib diisi"
                                : null,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    label: "Kode Pos",
                    icon: Icons.markunread_mailbox_outlined,
                    controller: kodePosController,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Kode pos wajib diisi";
                      if (int.tryParse(v) == null) {
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
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? "Alamat wajib diisi"
                                : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _jenisAkun,
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
                        if (v == null || v.isEmpty) return "Wajib diisi";
                        if (int.tryParse(v) == null) {
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
                        if (v == null || v.isEmpty) return "Wajib diisi";
                        if (int.tryParse(v) == null) {
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
                      validator:
                          (v) =>
                              v == null || v.isEmpty ? "Bio wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: "Keahlian (pisahkan dengan koma)",
                      icon: Icons.build_outlined,
                      controller: keahlianController,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? "Keahlian wajib diisi"
                                  : null,
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

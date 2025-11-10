import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rampungin_id_userside/core/api_client.dart';
import 'package:rampungin_id_userside/models/profile_model.dart';
import 'package:rampungin_id_userside/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final logger = Logger();
  final ProfileService _profileService = ProfileService();

  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _noTelpController;
  late TextEditingController _alamatController;
  late TextEditingController _kotaController;
  late TextEditingController _provinsiController;
  late TextEditingController _kodePosController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.profile.namaLengkap);
    _emailController = TextEditingController(text: widget.profile.email);
    _noTelpController = TextEditingController(text: widget.profile.noTelp);
    _alamatController = TextEditingController(text: widget.profile.alamat);
    _kotaController = TextEditingController(text: widget.profile.kota);
    _provinsiController = TextEditingController(text: widget.profile.provinsi);
    _kodePosController = TextEditingController(text: widget.profile.kodePos);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    _provinsiController.dispose();
    _kodePosController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await ApiClient().getToken();
      final authToken = token ?? '';

      if (authToken.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await _profileService.updateProfileJson(
        token: authToken,
        namaLengkap: _namaController.text,
        email: _emailController.text,
        noTelp: _noTelpController.text,
        alamat: _alamatController.text,
        kota: _kotaController.text,
        provinsi: _provinsiController.text,
        kodePos: _kodePosController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to reload profile
        } else {
          throw Exception(response['message'] ?? 'Gagal update profil');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        logger.e('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF3B950),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(200),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40000000),
                      offset: Offset(0, 4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(
                  15,
                  MediaQuery.of(context).padding.top + 20,
                  15,
                  40,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        margin: const EdgeInsets.only(top: 6),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 27,
                        ),
                      ),
                    ),
                    const SizedBox(width: 26),
                    const Expanded(
                      child: Text(
                        'EDIT PROFIL',
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Koulen',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _namaController,
                        label: 'Nama Lengkap',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama lengkap tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!value.contains('@')) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _noTelpController,
                        label: 'No. Telepon',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'No. telepon tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _alamatController,
                        label: 'Alamat',
                        icon: Icons.location_on,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Alamat tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _kotaController,
                        label: 'Kota',
                        icon: Icons.location_city,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kota tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _provinsiController,
                        label: 'Provinsi',
                        icon: Icons.map,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Provinsi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _kodePosController,
                        label: 'Kode Pos',
                        icon: Icons.markunread_mailbox,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kode pos tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3B950),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 4,
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFF3B950)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFF3B950),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFF3B950),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF3B950), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

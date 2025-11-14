import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class UbahPassword extends StatefulWidget {
  const UbahPassword({super.key});
 
  @override
  State<UbahPassword> createState() => _UbahPasswordState();
}

class _UbahPasswordState extends State<UbahPassword> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3B950),
        title: const Text(
          "Ubah Password",
          style: TextStyle(
            fontFamily: 'Koulen',
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 3,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFF3B950), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPasswordField(
                    controller: _oldPasswordController,
                    label: "Password Lama",
                    obscure: _obscureOld,
                    toggle: () => setState(() {
                      _obscureOld = !_obscureOld;
                    }),
                  ),
                  const SizedBox(height: 20),

                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: "Password Baru",
                    obscure: _obscureNew,
                    toggle: () => setState(() {
                      _obscureNew = !_obscureNew;
                    }),
                  ),
                  const SizedBox(height: 20),

                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: "Konfirmasi Password Baru",
                    obscure: _obscureConfirm,
                    toggle: () => setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    }),
                  ),

                  const SizedBox(height: 30),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3B950),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          fontFamily: 'Acme',
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Acme',
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDF6E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3B950), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: label,
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[700],
                ),
                onPressed: toggle,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

void _handleSave() async {
  final oldPass = _oldPasswordController.text.trim();
  final newPass = _newPasswordController.text.trim();
  final confirmPass = _confirmPasswordController.text.trim();

  if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
    _showError("Semua field wajib diisi!");
    return;
  }

  if (newPass != confirmPass) {
    _showError("Password baru dan konfirmasi tidak sama!");
    return;
  }

  try {
    // panggil API
    final _ = await AuthService().changePassword(
      oldPassword: oldPass,
      newPassword: newPass,
    );

    _showSuccess("Password berhasil diperbarui!");
    Navigator.pop(context);
  } catch (e) {
    _showError("Gagal memperbarui password. Pastikan password lama benar.");
  }
}

void _showSuccess(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color.fromARGB(255, 32, 180, 5), // hijau
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color.fromARGB(255, 255, 5, 5), // merah
      behavior: SnackBarBehavior.floating,
    ),
  );
}

}
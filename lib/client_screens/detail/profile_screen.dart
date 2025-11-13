import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rampungin_id_userside/core/api_client.dart';
import 'package:rampungin_id_userside/models/profile_model.dart';
import 'package:rampungin_id_userside/services/profile_service.dart';
import 'package:rampungin_id_userside/client_screens/detail/setting.dart';
import 'package:rampungin_id_userside/client_screens/detail/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final logger = Logger();
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  ProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  String _token = '';
  Uint8List? _selectedImageBytes;
  String? _selectedImageFilename;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get token from ApiClient (stored under 'jwt_token')
      final token = await ApiClient().getToken();
      _token = token ?? '';

      if (_token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      // Fetch profile
      final response = await _profileService.getProfile(_token);

      if (response['status'] == 'success') {
        setState(() {
          _profile = ProfileModel.fromJson(response['data']);
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Gagal mengambil data profil');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      logger.e('Error loading profile: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageFilename = image.name;
        });

        // Auto upload after selecting image
        _uploadProfilePhoto();
      }
    } catch (e) {
      logger.e('Error picking image: $e');
      _showErrorSnackBar('Gagal memilih foto');
    }
  }

  Future<void> _uploadProfilePhoto() async {
    if ((_selectedImageBytes == null && _selectedImageFilename == null) ||
        _profile == null) {
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await _profileService.updateProfileWithPhotoBytes(
        token: _token,
        namaLengkap: _profile!.namaLengkap,
        email: _profile!.email,
        noTelp: _profile!.noTelp,
        alamat: _profile!.alamat,
        kota: _profile!.kota,
        provinsi: _profile!.provinsi,
        kodePos: _profile!.kodePos,
        fotoProfilBytes: _selectedImageBytes!,
        fotoProfilFilename: _selectedImageFilename ?? 'profile.jpg',
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (response['status'] == 'success') {
        _showSuccessSnackBar('Foto profil berhasil diperbarui');
        _loadProfile(); // Reload profile
      } else {
        throw Exception(response['message'] ?? 'Gagal update foto profil');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      logger.e('Error uploading photo: $e');
      _showErrorSnackBar('Gagal mengupload foto profil');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorWidget()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3B950),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_profile == null) return const SizedBox();

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                // Header section with curved bottom
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
                    100,
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
                          'PROFILKU',
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

                // Profile image with edit icon and overlap
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x40000000),
                              offset: Offset(0, 4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 66,
                          backgroundColor: const Color(0xFFF3B950),
                          backgroundImage:
                              _selectedImageBytes != null
                                  ? MemoryImage(_selectedImageBytes!)
                                      as ImageProvider
                                  : (_profile!.fotoProfil != null &&
                                      _profile!.fotoProfil!.isNotEmpty)
                                  ? NetworkImage(
                                    _profile!.getFullImageUrl(
                                      'http://localhost/admintukang',
                                    ),
                                  )
                                  : null,
                          child:
                              (_selectedImageBytes == null &&
                                      (_profile!.fotoProfil == null ||
                                          _profile!.fotoProfil!.isEmpty))
                                  ? const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                      // Edit icon
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Name section
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Text(
                    _profile!.namaLengkap,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Acme',
                    ),
                  ),
                ),

                // Content area with profile information
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -10),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF6E8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFF3B950),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            offset: Offset(-3, -3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Information
                            _buildProfileItem('Username', _profile!.username),
                            const SizedBox(height: 16),
                            _buildProfileItem(
                              'Nama Lengkap',
                              _profile!.namaLengkap,
                            ),
                            const SizedBox(height: 16),
                            _buildProfileItem('Email', _profile!.email),
                            const SizedBox(height: 16),
                            _buildProfileItem('No. Telepon', _profile!.noTelp),
                            const SizedBox(height: 16),
                            _buildProfileItem('Alamat', _profile!.alamat),
                            const SizedBox(height: 16),
                            _buildProfileItem('Kota', _profile!.kota),
                            const SizedBox(height: 16),
                            _buildProfileItem('Provinsi', _profile!.provinsi),
                            const SizedBox(height: 16),
                            _buildProfileItem('Kode Pos', _profile!.kodePos),
                            const SizedBox(height: 16),
                            _buildProfileItem(
                              'Poin',
                              _profile!.poin.toString(),
                            ),
                            const SizedBox(height: 20),

                            // Edit Profile Button
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Navigate to edit profile screen
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => EditProfileScreen(
                                            profile: _profile!,
                                          ),
                                    ),
                                  );

                                  // Reload profile if updated
                                  if (result == true) {
                                    _loadProfile();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF3B950),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Settings icon at bottom
                Transform.translate(
                  offset: const Offset(0, 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Setting()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 30),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'SETTING',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFF3B950).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

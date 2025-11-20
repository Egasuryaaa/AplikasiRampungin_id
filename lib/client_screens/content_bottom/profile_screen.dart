// File: lib/client_screens/content_bottom/profile_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rampungin_id_userside/models/profile_model.dart';
import 'package:rampungin_id_userside/services/profile_service.dart';
import 'package:rampungin_id_userside/client_screens/detail/setting.dart';
import 'package:rampungin_id_userside/client_screens/detail/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final logger = Logger();
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  ProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageFilename;

  @override
  bool get wantKeepAlive => true;

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
      // Token parameter is ignored - ApiClient handles it automatically
      final response = await _profileService.getProfile('');

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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await _profileService.updateProfileWithPhotoBytes(
        token: '', // Token parameter is ignored - ApiClient handles it
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

      if (mounted) Navigator.pop(context);

      if (response['status'] == 'success') {
        _showSuccessSnackBar('Foto profil berhasil diperbarui');
        _loadProfile();
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

  Widget _buildProfileImageContent() {
    if (_selectedImageBytes != null) {
      return CircleAvatar(
        radius: 66,
        backgroundColor: const Color(0xFFF3B950),
        backgroundImage: MemoryImage(_selectedImageBytes!),
      );
    }

    if (_profile?.fotoProfil == null || _profile!.fotoProfil!.isEmpty) {
      return const CircleAvatar(
        radius: 66,
        backgroundColor: Color(0xFFF3B950),
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.white,
        ),
      );
    }

    // Construct the image URL
    String imageUrl = _profile!.fotoProfil!;
    
    if (!imageUrl.startsWith('http')) {
      if (!imageUrl.startsWith('uploads/')) {
        imageUrl = 'uploads/$imageUrl';
      }
      imageUrl = 'https://api.iwakrejosari.com/$imageUrl';
    }

    logger.d('Loading client profile image from: $imageUrl');

    return CircleAvatar(
      radius: 66,
      backgroundColor: const Color(0xFFF3B950),
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (exception, stackTrace) {
        logger.e('Error loading client profile image: $exception');
      },
      child: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      body: _isLoading
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
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

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildProfileImage(),
          const SizedBox(height: 10),
          Text(
            _profile!.namaLengkap,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Acme',
            ),
          ),
          const SizedBox(height: 20),
          _buildProfileInfo(),
          const SizedBox(height: 20),
          _buildSettingsButton(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFBB41),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(100)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(25, 12, 25, 40),
      child: const Text(
        'PROFILKU',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          fontFamily: 'KdamThmorPro',
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
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
          child: _buildProfileImageContent(),
        ),
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
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3B950), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(-3, -3),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileItem('Username', _profile!.username),
          const SizedBox(height: 16),
          _buildProfileItem('Nama Lengkap', _profile!.namaLengkap),
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
          _buildProfileItem('Poin', _profile!.poin.toString()),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(profile: _profile!),
                  ),
                );
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

  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Setting()),
        );
      },
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
    );
  }
}
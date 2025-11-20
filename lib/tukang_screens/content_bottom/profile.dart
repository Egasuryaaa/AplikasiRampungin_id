// File: lib/tukang_screens/content_bottom/profile.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rampungin_id_userside/tukang_screens/detail/edit_profile.dart';
import 'package:rampungin_id_userside/models/tukang_profile_model.dart';
import 'package:rampungin_id_userside/services/tukang_service.dart';
import 'package:rampungin_id_userside/tukang_screens/detail/setting.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final logger = Logger();
  final TukangService _tukangService = TukangService();

  bool _isLoading = true;
  TukangProfileModel? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);

      final profile = await _tukangService.getProfileFull();

      setState(() {
        _profileData = profile;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading profile: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfile()),
    );

    if (result == true) {
      _loadProfile();
    }
  }

  // FIXED: Build profile image with proper URL handling
  Widget _buildProfileImage() {
    return Transform.translate(
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
            child: ClipOval(
              child: _buildProfileImageContent(),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: _navigateToEditProfile,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3B950),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Build profile image content with correct URL
  Widget _buildProfileImageContent() {
    if (_profileData?.fotoProfil == null || _profileData!.fotoProfil!.isEmpty) {
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

    // FIXED: Properly construct the image URL
    String imageUrl = _profileData!.fotoProfil!;
    
    // If the path doesn't start with http, add the base URL
    if (!imageUrl.startsWith('http')) {
      // If path doesn't start with uploads/, add it
      if (!imageUrl.startsWith('uploads/')) {
        imageUrl = 'uploads/$imageUrl';
      }
      imageUrl = 'https://api.iwakrejosari.com/$imageUrl';
    }

    logger.d('Loading profile image from: $imageUrl');

    return Image.network(
      imageUrl,
      width: 140,
      height: 140,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: const Color(0xFFF3B950),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        logger.e('Error loading profile image: $error');
        return const CircleAvatar(
          radius: 66,
          backgroundColor: Color(0xFFF3B950),
          child: Icon(
            Icons.person,
            size: 80,
            color: Colors.white,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3B950),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Setting()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF3B950)),
            )
          : SafeArea(
              child: SingleChildScrollView(
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
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                      child: const Center(
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
                    ),

                    // FIXED: Profile image with proper URL handling
                    _buildProfileImage(),

                    // Name section
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Text(
                        _profileData?.namaLengkap ?? 'Nama Tukang',
                        style: const TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Content area with profile information
                    Transform.translate(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileItem(
                              'Nama Lengkap',
                              _profileData?.namaLengkap ?? '-',
                            ),
                            const SizedBox(height: 16),
                            _buildProfileItem(
                              'Email',
                              _profileData?.email ?? '-',
                            ),
                            const SizedBox(height: 16),
                            _buildProfileItem(
                              'No. Telepon',
                              _profileData?.noTelp ?? '-',
                            ),
                            const SizedBox(height: 16),
                            _buildProfileItem(
                              'Alamat',
                              _profileData?.alamat ?? '-',
                            ),
                            const SizedBox(height: 16),
                            _buildProfileItem(
                              'Kota',
                              _profileData?.kota ?? '-',
                            ),
                            const SizedBox(height: 16),
                            _buildProfileItem(
                              'Provinsi',
                              _profileData?.provinsi ?? '-',
                            ),
                            if (_profileData?.profilTukang != null) ...[
                              const SizedBox(height: 16),
                              _buildProfileItem(
                                'Pengalaman',
                                '${_profileData!.profilTukang!.pengalamanTahun ?? 0} tahun',
                              ),
                              const SizedBox(height: 16),
                              _buildProfileItem(
                                'Tarif per Jam',
                                'Rp ${(_profileData!.profilTukang!.tarifPerJam ?? 0).toStringAsFixed(0)}',
                              ),
                              const SizedBox(height: 16),
                              _buildProfileItem(
                                'Bio',
                                _profileData!.profilTukang!.bio ?? '-',
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Edit Profile Button
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _navigateToEditProfile,
                                icon: const Icon(Icons.edit, size: 20),
                                label: const Text('Edit Profile'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF3B950),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFF3B950).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
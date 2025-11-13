import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rampungin_id_userside/tukang_screens/detail/setting.dart';
import 'package:rampungin_id_userside/tukang_screens/detail/edit_profile.dart';
import 'package:rampungin_id_userside/models/tukang_profile_model.dart';
import 'package:rampungin_id_userside/services/tukang_service.dart';

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

    // Reload profile if edit was successful
    if (result == true) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF3B950)),
              )
              : SizedBox(
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
                                  child: const CircleAvatar(
                                    radius: 66,
                                    backgroundColor: Color(0xFFF3B950),
                                    child: Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Edit icon
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
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
                              _profileData?.namaLengkap ?? 'Nama Tukang',
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Profile Information
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
                                      if (_profileData?.profilTukang !=
                                          null) ...[
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
                                          _profileData!.profilTukang!.bio ??
                                              '-',
                                        ),
                                      ],
                                      const SizedBox(height: 20),

                                      // Edit Profile Button
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: _navigateToEditProfile,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFF3B950,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                  MaterialPageRoute(
                                    builder: (context) => Setting(),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 20,
                                  bottom: 30,
                                ),
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

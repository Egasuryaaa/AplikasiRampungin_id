import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:rampungin_id_userside/client_screens/detail/setting.dart';
import 'package:rampungin_id_userside/services/client_service.dart';
import 'package:rampungin_id_userside/models/profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final logger = Logger();
  final ClientService _clientService = ClientService();
  
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

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
      final profile = await _clientService.getProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      logger.e('Error loading profile: $e');
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
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : CircleAvatar(
                                  radius: 66,
                                  backgroundColor: const Color(0xFFF3B950),
                                  backgroundImage: _profile?.fotoProfilUrl != null
                                      ? NetworkImage(_profile!.fotoProfilUrl!)
                                      : null,
                                  child: _profile?.fotoProfilUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                        ),
                        // Edit icon
                        if (!_isLoading)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Implement photo picker
                                logger.i('Edit photo tapped');
                              },
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
                          ),
                      ],
                    ),
                  ),

                  // Name section
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: Text(
                      _profile?.namaLengkap ?? 'Nama',
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
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _errorMessage != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _errorMessage!,
                                          style: const TextStyle(color: Colors.red),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _loadProfile,
                                          child: const Text('Coba Lagi'),
                                        ),
                                      ],
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Profile Information
                                        _buildProfileItem(
                                          'Username',
                                          _profile?.username ?? '-',
                                        ),
                                        const SizedBox(height: 16),
                                        _buildProfileItem(
                                          'Nama Lengkap',
                                          _profile?.namaLengkap ?? '-',
                                        ),
                                        const SizedBox(height: 16),
                                        _buildProfileItem(
                                          'Email',
                                          _profile?.email ?? '-',
                                        ),
                                        const SizedBox(height: 16),
                                        _buildProfileItem(
                                          'No. Telepon',
                                          _profile?.noTelp ?? '-',
                                        ),
                                        const SizedBox(height: 16),
                                        _buildProfileItem(
                                          'Alamat',
                                          _profile?.alamat ?? '-',
                                        ),
                                        const SizedBox(height: 16),
                                        _buildProfileItem(
                                          'Kota',
                                          _profile?.kota ?? '-',
                                        ),
                                        const SizedBox(height: 16),
                                        _buildProfileItem(
                                          'Provinsi',
                                          _profile?.provinsi ?? '-',
                                        ),
                                        const SizedBox(height: 16),
                                        _buildProfileItem(
                                          'Kode Pos',
                                          _profile?.kodePos ?? '-',
                                        ),
                                        const SizedBox(height: 16),
                                        _buildProfileItem(
                                          'Poin',
                                          _profile?.poin?.toString() ?? '0',
                                        ),
                                        const SizedBox(height: 20),

                                        // Edit Profile Button
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // TODO: Navigate to edit profile page
                                              logger.i('Edit profile tapped');
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

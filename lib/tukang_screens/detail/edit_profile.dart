import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rampungin_id_userside/models/tukang_profile_model.dart';
import 'package:rampungin_id_userside/models/category_model.dart';
import 'package:rampungin_id_userside/services/tukang_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TukangService _tukangService = TukangService();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoadingCategories = false;

  // Categories
  List<CategoryModel> _allCategories = [];
  List<int> _selectedCategoryIds = [];

  // Photo
  XFile? _selectedImageXFile; // Keep XFile for filename
  String? _currentPhotoUrl;
  Uint8List? _selectedImageBytes;

  // Text controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _provinsiController = TextEditingController();
  final TextEditingController _pengalamanController = TextEditingController();
  final TextEditingController _tarifController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _keahlianController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  final TextEditingController _namaBankController = TextEditingController();
  final TextEditingController _nomorRekeningController =
      TextEditingController();
  final TextEditingController _namaPemilikController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadCategories();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    _provinsiController.dispose();
    _pengalamanController.dispose();
    _tarifController.dispose();
    _bioController.dispose();
    _keahlianController.dispose();
    _radiusController.dispose();
    _namaBankController.dispose();
    _nomorRekeningController.dispose();
    _namaPemilikController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);

      final profile = await _tukangService.getProfileFull();

      setState(() {
        _populateFields(profile);
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading profile: $e', name: 'EditProfile');
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

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoadingCategories = true);

      final categories = await _tukangService.getCategories();

      setState(() {
        _allCategories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      developer.log('Error loading categories: $e', name: 'EditProfile');
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageXFile = image; // Save XFile
          _selectedImageBytes = Uint8List.fromList(bytes);
        });
      }
    } catch (e) {
      developer.log('Error picking image: $e', name: 'EditProfile');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _populateFields(TukangProfileModel profile) {
    _namaController.text = profile.namaLengkap ?? '';
    _emailController.text = profile.email ?? '';
    _noTelpController.text = profile.noTelp ?? '';
    _alamatController.text = profile.alamat ?? '';
    _kotaController.text = profile.kota ?? '';
    _provinsiController.text = profile.provinsi ?? '';

    // Set current photo URL
    _currentPhotoUrl = profile.fotoProfil;

    // Set selected category IDs
    if (profile.kategori != null) {
      _selectedCategoryIds =
          profile.kategori!.map((e) => e.id).whereType<int>().toList();
    }

    if (profile.profilTukang != null) {
      final profilTukang = profile.profilTukang!;
      _pengalamanController.text =
          profilTukang.pengalamanTahun?.toString() ?? '0';
      _tarifController.text =
          profilTukang.tarifPerJam?.toStringAsFixed(0) ?? '0';
      _bioController.text = profilTukang.bio ?? '';
      _radiusController.text = profilTukang.radiusLayananKm?.toString() ?? '0';
      _namaBankController.text = profilTukang.namaBank ?? '';
      _nomorRekeningController.text = profilTukang.nomorRekening ?? '';
      _namaPemilikController.text = profilTukang.namaPemilikRekening ?? '';

      // Join keahlian array to comma-separated string
      if (profilTukang.keahlian != null && profilTukang.keahlian!.isNotEmpty) {
        _keahlianController.text = profilTukang.keahlian!.join(', ');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() => _isSaving = true);

      // Parse keahlian from comma-separated string to list
      final keahlianList =
          _keahlianController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      // Get image bytes and filename if selected
      List<int>? fotoProfilBytes;
      String? fotoProfilFilename;

      // Use the bytes we already have from _pickImage()
      if (_selectedImageBytes != null && _selectedImageXFile != null) {
        try {
          // Limit file size to 2MB to avoid issues with large payloads
          if (_selectedImageBytes!.length > 2 * 1024 * 1024) {
            throw Exception('Ukuran foto terlalu besar. Maksimal 2MB');
          }

          fotoProfilBytes = _selectedImageBytes!;
          fotoProfilFilename = _selectedImageXFile!.name;
          developer.log(
            'Image prepared for upload, size: ${_selectedImageBytes!.length} bytes, filename: $fotoProfilFilename',
            name: 'EditProfile',
          );
        } catch (e) {
          developer.log('Error preparing image: $e', name: 'EditProfile');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal memproses foto: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isSaving = false);
          return;
        }
      }

      await _tukangService.updateProfileFull(
        namaLengkap: _namaController.text,
        email: _emailController.text,
        noTelp: _noTelpController.text,
        alamat: _alamatController.text,
        kota: _kotaController.text,
        provinsi: _provinsiController.text,
        pengalamanTahun: int.tryParse(_pengalamanController.text) ?? 0,
        tarifPerJam: double.tryParse(_tarifController.text) ?? 0,
        bio: _bioController.text,
        keahlian: keahlianList,
        radiusLayananKm: int.tryParse(_radiusController.text) ?? 0,
        namaBank: _namaBankController.text,
        nomorRekening: _nomorRekeningController.text,
        namaPemilikRekening: _namaPemilikController.text,
        kategoriIds:
            _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds : null,
        fotoProfilBytes: fotoProfilBytes,
        fotoProfilFilename: fotoProfilFilename,
      );

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      developer.log('Error saving profile: $e', name: 'EditProfile');
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: $e'),
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
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF3B950)),
              )
              : SingleChildScrollView(
                child: Column(children: [_buildHeader(), _buildForm()]),
              ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3B950),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(200)),
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
        60,
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
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Foto Profil'),
            const SizedBox(height: 16),
            _buildPhotoSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Informasi Pribadi'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _namaController,
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama lengkap wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Masukkan email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email wajib diisi';
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
              hint: 'Masukkan nomor telepon',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor telepon wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _alamatController,
              label: 'Alamat',
              hint: 'Masukkan alamat lengkap',
              icon: Icons.location_on,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _kotaController,
                    label: 'Kota',
                    hint: 'Kota',
                    icon: Icons.location_city,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kota wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _provinsiController,
                    label: 'Provinsi',
                    hint: 'Provinsi',
                    icon: Icons.map,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Provinsi wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Informasi Tukang'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _pengalamanController,
                    label: 'Pengalaman (Tahun)',
                    hint: '0',
                    icon: Icons.work,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _tarifController,
                    label: 'Tarif per Jam (Rp)',
                    hint: '0',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _radiusController,
              label: 'Radius Layanan (KM)',
              hint: '0',
              icon: Icons.location_searching,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Radius layanan wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _bioController,
              label: 'Bio / Deskripsi',
              hint: 'Ceritakan tentang keahlian dan pengalaman Anda',
              icon: Icons.description,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bio wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _keahlianController,
              label: 'Keahlian (pisahkan dengan koma)',
              hint: 'Contoh: Instalasi listrik, Perbaikan listrik',
              icon: Icons.build,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Keahlian wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Kategori Keahlian'),
            const SizedBox(height: 16),
            _buildCategorySection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Informasi Bank'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _namaBankController,
              label: 'Nama Bank',
              hint: 'Contoh: BCA, Mandiri, BRI',
              icon: Icons.account_balance,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama bank wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nomorRekeningController,
              label: 'Nomor Rekening',
              hint: 'Masukkan nomor rekening',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor rekening wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _namaPemilikController,
              label: 'Nama Pemilik Rekening',
              hint: 'Sesuai kartu ATM',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama pemilik rekening wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3B950),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
                child:
                    _isSaving
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'SIMPAN PERUBAHAN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF3B950),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFF3B950)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF3B950), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFFF3B950).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF3B950), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
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

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF3B950), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child:
                    _selectedImageBytes != null
                        ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                        : _currentPhotoUrl != null
                        ? Image.network(
                          'http://localhost/admintukang/${_currentPhotoUrl!}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 80,
                              color: Color(0xFFF3B950),
                            );
                          },
                        )
                        : const Icon(
                          Icons.person,
                          size: 80,
                          color: Color(0xFFF3B950),
                        ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Ubah Foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3B950),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    if (_isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF3B950)),
      );
    }

    if (_allCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tidak ada kategori tersedia',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih kategori keahlian Anda (bisa lebih dari satu)',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _allCategories.map((category) {
                final isSelected = _selectedCategoryIds.contains(category.id);
                return FilterChip(
                  label: Text(category.nama ?? 'Unknown'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (category.id != null) {
                          _selectedCategoryIds.add(category.id!);
                        }
                      } else {
                        _selectedCategoryIds.remove(category.id);
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFFF3B950).withValues(alpha: 0.3),
                  checkmarkColor: const Color(0xFFF3B950),
                  labelStyle: TextStyle(
                    color:
                        isSelected ? const Color(0xFFF3B950) : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color:
                        isSelected
                            ? const Color(0xFFF3B950)
                            : Colors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                );
              }).toList(),
        ),
        if (_selectedCategoryIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Pilih minimal 1 kategori',
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          ),
      ],
    );
  }
}

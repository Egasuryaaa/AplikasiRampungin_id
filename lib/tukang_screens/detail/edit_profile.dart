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

  Map<int, List<TextEditingController>> _keahlianPerKategori = {};
  int? _kategoriAktif;

  // Photo
  XFile? _selectedImageXFile;
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

  // CHANGED: List of controllers for dynamic skills
  List<TextEditingController> _Controllers = [TextEditingController()];

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

    // Dispose all keahlian controllers
    for (var controller in _Controllers) {
      controller.dispose();
    }

    // Dispose keahlian per kategori controllers
    for (var kategoriControllers in _keahlianPerKategori.values) {
      for (var controller in kategoriControllers) {
        controller.dispose();
      }
    }

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
          _selectedImageXFile = image;
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

 // FIXED: _populateFields method with proper category handling
void _populateFields(TukangProfileModel profile) {
  _namaController.text = profile.namaLengkap ?? '';
  _emailController.text = profile.email ?? '';
  _noTelpController.text = profile.noTelp ?? '';
  _alamatController.text = profile.alamat ?? '';
  _kotaController.text = profile.kota ?? '';
  _provinsiController.text = profile.provinsi ?? '';

  _currentPhotoUrl = profile.fotoProfil;

  // FIXED: Handle kategori properly
  if (profile.kategori != null && profile.kategori!.isNotEmpty) {
    _selectedCategoryIds = profile.kategori!
        .map((e) => e.id)
        .whereType<int>()
        .toList();
    
    // Set first category as active
    if (_selectedCategoryIds.isNotEmpty) {
      _kategoriAktif = _selectedCategoryIds.first;
    }
    
    // FIXED: Initialize keahlian per kategori from existing data
    // Since the backend doesn't store skills per category separately,
    // we'll need to initialize empty controllers for each category
    for (var categoryId in _selectedCategoryIds) {
      _keahlianPerKategori.putIfAbsent(
        categoryId,
        () => [TextEditingController()],
      );
    }
  } else {
    // No categories selected yet - this is fine for new/incomplete profiles
    _selectedCategoryIds = [];
    _kategoriAktif = null;
    _keahlianPerKategori = {};
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

    // FIXED: Handle keahlian properly
    // Populate the old keahlian system (fallback)
    if (profilTukang.keahlian != null && profilTukang.keahlian!.isNotEmpty) {
      // Dispose old controllers
      for (var controller in _Controllers) {
        controller.dispose();
      }

      // Create new controllers for each skill
      _Controllers = profilTukang.keahlian!
          .map((skill) => TextEditingController(text: skill))
          .toList();

      // ADDED: If we have categories and skills, distribute skills to categories
      if (_selectedCategoryIds.isNotEmpty) {
        // For now, put all existing skills in the first active category
        if (_kategoriAktif != null) {
          _keahlianPerKategori[_kategoriAktif!] = profilTukang.keahlian!
              .map((skill) => TextEditingController(text: skill))
              .toList();
        }
      }
    } else {
      // Ensure at least one empty controller
      _Controllers = [TextEditingController()];
    }
  }
}

// IMPROVED: _saveProfile with better validation
Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  try {
    setState(() => _isSaving = true);

    // CHANGED: Parse keahlian from controllers - collect from all selected categories
    List<String> keahlianList = [];
    
    if (_selectedCategoryIds.isNotEmpty) {
      // Collect skills from all selected categories
      for (var categoryId in _selectedCategoryIds) {
        if (_keahlianPerKategori.containsKey(categoryId)) {
          final categorySkills = _keahlianPerKategori[categoryId]!
              .map((controller) => controller.text.trim())
              .where((text) => text.isNotEmpty)
              .toList();
          keahlianList.addAll(categorySkills);
        }
      }
    } else {
      // Use skills from old system
      keahlianList = _Controllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
    }

    // IMPROVED: Better validation message
    if (keahlianList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal 1 keahlian wajib diisi untuk setiap kategori yang dipilih'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    // IMPROVED: Validate that at least one category is selected
    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal 1 kategori harus dipilih'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    // Get image bytes and filename if selected
    List<int>? fotoProfilBytes;
    String? fotoProfilFilename;

    if (_selectedImageBytes != null && _selectedImageXFile != null) {
      try {
        if (_selectedImageBytes!.length > 2 * 1024 * 1024) {
          throw Exception('Ukuran foto terlalu besar. Maksimal 2MB');
        }

        fotoProfilBytes = _selectedImageBytes!;
        fotoProfilFilename = _selectedImageXFile!.name;
      } catch (e) {
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
      kategoriIds: _selectedCategoryIds,  // Always send category IDs
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
      Navigator.pop(context, true);
    }
  } catch (e) {
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

  // NEW: Function to get current category progress
  String _getCurrentCategoryProgress() {
    if (_kategoriAktif == null) return '';
    
    final currentIndex = _allCategories.indexWhere((c) => c.id == _kategoriAktif);
    if (currentIndex == -1) return '';
    
    return 'Kategori ${currentIndex + 1} dari ${_allCategories.length}';
  }

  // NEW: Function to get list of selected categories with their skills
  Widget _buildSelectedCategoriesList() {
    if (_selectedCategoryIds.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Kategori yang Dipilih:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF3B950),
          ),
        ),
        const SizedBox(height: 8),
        ..._selectedCategoryIds.map((categoryId) {
          final category = _allCategories.firstWhere((c) => c.id == categoryId);
          final skills = _keahlianPerKategori[categoryId] ?? [];
          final skillTexts = skills
              .map((controller) => controller.text.trim())
              .where((text) => text.isNotEmpty)
              .toList();
          
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF3B950).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.nama ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (skillTexts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Keahlian: ${skillTexts.join(', ')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
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

            // Keahlian section (old system - fallback)
            if (_kategoriAktif == null && _selectedCategoryIds.isEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Keahlian'),
              const SizedBox(height: 16),
              _buildKeahlianSection(),
            ],

            const SizedBox(height: 24),
            _buildSectionTitle('Kategori Keahlian'),
            const SizedBox(height: 16),
            _buildCategorySection(),
            
            // NEW: Show selected categories list
            _buildSelectedCategoriesList(),
            
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

  // ADDED: Missing _buildSectionTitle method
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

  // ADDED: Missing _buildTextField method
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
                color: const Color(0xFFF3B950).withOpacity(0.3),
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

  // ADDED: Missing _buildPhotoSection method
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
                    color: Colors.black.withOpacity(0.1),
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
                          'https://api.iwakrejosari.com/${_currentPhotoUrl!}',
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

  // Build dynamic keahlian section
  Widget _buildKeahlianSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keahlian',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // List of skill inputs
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _Controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input field
                  Expanded(
                    child: TextFormField(
                      controller: _Controllers[index],
                      decoration: InputDecoration(
                        hintText: 'Contoh: Instalasi listrik',
                        prefixIcon: const Icon(
                          Icons.build,
                          color: Color(0xFFF3B950),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFF3B950),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFFF3B950).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFF3B950),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        // Only validate if it's the only field
                        if (index == 0 && (value == null || value.isEmpty)) {
                          return 'Minimal 1 keahlian wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Add/Remove buttons
                  if (index == _Controllers.length - 1)
                    // Add button on last item
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _Controllers.add(TextEditingController());
                          });
                        },
                        tooltip: 'Tambah keahlian',
                      ),
                    )
                  else
                    // Remove button on other items
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _Controllers[index].dispose();
                            _Controllers.removeAt(index);
                          });
                        },
                        tooltip: 'Hapus keahlian',
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        // Helper text
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Text(
            'Klik tombol + untuk menambah keahlian lainnya',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
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
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
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
          'Pilih kategori keahlian Anda (bisa memilih lebih dari satu)',
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
                          // ADD category to selected list
                          _selectedCategoryIds.add(category.id!);
                          _kategoriAktif = category.id!;
                          _keahlianPerKategori.putIfAbsent(
                            category.id!,
                            () => [TextEditingController()],
                          );
                        }
                      } else {
                        // REMOVE category from selected list
                        _selectedCategoryIds.remove(category.id!);
                        if (_kategoriAktif == category.id) {
                          _kategoriAktif = _selectedCategoryIds.isNotEmpty 
                              ? _selectedCategoryIds.first 
                              : null;
                        }
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFFF3B950).withOpacity(0.3),
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
                            : Colors.grey.withOpacity(0.3),
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
        if (_selectedCategoryIds.isNotEmpty && _kategoriAktif != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: _buildKeahlianPerKategoriSection(_kategoriAktif!),
          ),
      ],
    );
  }

  // Build keahlian section for specific kategori
  Widget _buildKeahlianPerKategoriSection(int kategoriId) {
    final controllers = _keahlianPerKategori[kategoriId] ?? [TextEditingController()];
    final currentCategory = _allCategories.firstWhere((c) => c.id == kategoriId);
    final currentIndex = _allCategories.indexWhere((c) => c.id == kategoriId);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category progress indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3B950).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3B950).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.category, color: const Color(0xFFF3B950), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Kategori Keahlian:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF3B950),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currentCategory.nama ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getCurrentCategoryProgress(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Keahlian untuk ${currentCategory.nama}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // List of skill inputs for this category
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input field
                  Expanded(
                    child: TextFormField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        hintText: 'isi keahlian Anda sesuai kategori ini',
                        prefixIcon: const Icon(
                          Icons.build,
                          color: Color(0xFFF3B950),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFF3B950),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFFF3B950).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFF3B950),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        // Only validate if it's the only field
                        if (index == 0 && (value == null || value.isEmpty)) {
                          return 'Minimal 1 keahlian wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Add/Remove buttons
                  if (index == controllers.length - 1)
                    // Add button on last item
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            controllers.add(TextEditingController());
                          });
                        },
                        tooltip: 'Tambah keahlian',
                      ),
                    )
                  else
                    // Remove button on other items
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            controllers[index].dispose();
                            controllers.removeAt(index);
                          });
                        },
                        tooltip: 'Hapus keahlian',
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        // Helper text
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Text(
            'Klik tombol + untuk menambah keahlian lainnya',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // Next category button
        if (_kategoriAktif != null) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3B950),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                final currentIndex = _allCategories.indexWhere((c) => c.id == _kategoriAktif);
                if (currentIndex < _allCategories.length - 1) {
                  setState(() {
                    // Find next category that is not yet selected
                    int nextIndex = currentIndex + 1;
                    while (nextIndex < _allCategories.length && 
                           _selectedCategoryIds.contains(_allCategories[nextIndex].id)) {
                      nextIndex++;
                    }
                    
                    if (nextIndex < _allCategories.length) {
                      _kategoriAktif = _allCategories[nextIndex].id;
                      if (!_selectedCategoryIds.contains(_kategoriAktif)) {
                        _selectedCategoryIds.add(_kategoriAktif!);
                      }
                      _keahlianPerKategori.putIfAbsent(
                        _kategoriAktif!,
                        () => [TextEditingController()],
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Semua kategori sudah dipilih'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua kategori sudah dipilih'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Lanjut ke Kategori Berikutnya',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
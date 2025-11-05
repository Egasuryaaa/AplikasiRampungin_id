import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../content_bottom/home_screen.dart';

class FormTukang extends StatefulWidget {
  const FormTukang({super.key});

  @override
  State<FormTukang> createState() => _FormTukangState();
}

class _FormTukangState extends State<FormTukang> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  String _selectedCategory = '';
  String _selectedSubCategory = '';
  bool _ktpImageSelected = false;
  bool _showSubCategory = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Fixed category structure
  final Map<String, List<String>> _categories = {
    'Tukang Bangunan': [
      'Tukang Batu',
      'Tukang Kayu',
      'Tukang Besi',
      'Tukang Atap',
    ],
    'Tukang Elektronik': [
      'Tukang AC',
      'Tukang Kulkas/Mesin Cuci',
      'Tukang Listrik',
      'Tukang TV/Radio',
    ],
    'Tukang Cat': ['Cat Tembok', 'Cat Kayu', 'Cat Besi', 'Cat Dekoratif'],
    'Tukang Cleaning Service': [
      'Cleaning Rumah',
      'Cleaning Kantor',
      'Cleaning Karpet',
      'Cleaning AC',
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_ktpImageSelected) {
        _showSnackBar('Mohon upload foto KTP terlebih dahulu', Colors.orange);
        return;
      }

      // Show success animation
      _showSnackBar('Data berhasil disubmit!', Colors.green);

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    } else {
      _showSnackBar('Mohon lengkapi semua field yang diperlukan', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green
                  ? Icons.check_circle
                  : color == Colors.orange
                  ? Icons.warning
                  : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickKTPImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _ktpImageSelected = true;
        });
        _showSnackBar('Foto KTP berhasil diambil', Colors.green);

        // Di sini Anda bisa menggunakan image.path untuk mengupload ke server
        // atau menyimpan path-nya untuk keperluan lain
        debugPrint('Foto KTP path: ${image.path}');
      }
    } catch (e) {
      _showSnackBar('Gagal mengambil foto: $e', Colors.red);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF3B950), // warna header date picker
              onPrimary: Colors.black, // warna teks di atas warna utama
              onSurface: Colors.black, // warna teks tanggal
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.exit_to_app, color: Colors.orange[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'kembali',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin kembali ke halaman home? Data yang belum disimpan akan hilang.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFE55353)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _exitToHome();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'kembali',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _exitToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isDateField = false,
    double width = 286,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Acme',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: width,
            constraints: const BoxConstraints(minHeight: 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
              border: Border.all(
                color: const Color(0xFFF3B950).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              readOnly: isDateField,
              onTap: isDateField ? _selectDate : null,
              style: const TextStyle(
                fontFamily: 'Abel',
                fontSize: 14,
                color: Color(0xFF2C2C2C),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Abel',
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon:
                    isDateField
                        ? const Icon(
                          Icons.calendar_today,
                          color: Color(0xFFF3B950),
                          size: 20,
                        )
                        : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hintText,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Acme',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 286,
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
              border: Border.all(
                color: const Color(0xFFF3B950).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: DropdownButtonFormField<String>(
              initialValue:
                  _selectedCategory.isEmpty
                      ? null
                      : _selectedCategory, // fix null value (use 'value' over deprecated 'initialValue')
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih kategori';
                }
                return null;
              },
              hint: Text(
                hintText,
                style: const TextStyle(
                  fontFamily: 'Abel',
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFFF3B950),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2C2C2C)),
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Enhanced Header with Exit Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFF3B950), Color(0xFFE8A63C)],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFF3B950,
                                ).withValues(alpha: 0.4),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                          child: Column(
                            children: [
                              // Header with Exit Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: _showExitDialog,
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Verifikasi Tukang',
                                    style: TextStyle(
                                      fontFamily: 'Acme',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 48,
                                  ), // Untuk balance layout
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Icon(
                                Icons.verified_user,
                                size: 48,
                                color: Colors.black87,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'LENGKAPI DATA DIRI',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Acme',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 3,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Enhanced description
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFF3B950,
                                      ).withValues(alpha: 0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Lengkapi data dengan benar untuk proses verifikasi yang lebih cepat',
                                          style: TextStyle(
                                            fontFamily: 'Abel',
                                            fontSize: 12,
                                            height: 1.4,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Form Fields
                                Expanded(
                                  child: ListView(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    children: [
                                      _buildInputField(
                                        label: 'Nama Lengkap',
                                        controller: _nameController,
                                        hintText: 'Masukkan nama lengkap Anda',
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Nama tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      _buildInputField(
                                        label: 'Alamat Lengkap',
                                        controller: _addressController,
                                        hintText:
                                            'Masukkan alamat lengkap Anda',
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Alamat tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Birth Place and Date Row
                                      const Text(
                                        'Tempat & Tanggal Lahir',
                                        style: TextStyle(
                                          fontFamily: 'Acme',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2C2C2C),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInputField(
                                              label: '',
                                              controller: _birthPlaceController,
                                              hintText: 'Tempat Lahir',
                                              width: double.infinity,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Wajib diisi';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildInputField(
                                              label: '',
                                              controller: _birthDateController,
                                              hintText: 'Tanggal Lahir',
                                              width: double.infinity,
                                              isDateField: true,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Wajib diisi';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Category Dropdown
                                      _buildDropdownField(
                                        label: 'Kategori Keahlian',
                                        value: _selectedCategory,
                                        items: _categories.keys.toList(),
                                        hintText: 'Pilih kategori keahlian',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Pilih kategori keahlian';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCategory = value!;
                                            _selectedSubCategory = '';
                                            _showSubCategory =
                                                _categories[value]!.isNotEmpty;
                                          });
                                        },
                                      ),

                                      // Animated Sub-category Dropdown
                                      AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        child:
                                            _showSubCategory
                                                ? Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const SizedBox(height: 16),
                                                    _buildDropdownField(
                                                      label: 'Spesialisasi',
                                                      value:
                                                          _selectedSubCategory,
                                                      items:
                                                          _categories[_selectedCategory] ??
                                                          [],
                                                      hintText:
                                                          'Pilih spesialisasi Anda',
                                                      validator: (value) {
                                                        if (_showSubCategory &&
                                                            (value == null ||
                                                                value
                                                                    .isEmpty)) {
                                                          return 'Pilih spesialisasi';
                                                        }
                                                        return null;
                                                      },
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _selectedSubCategory =
                                                              value!;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                )
                                                : const SizedBox.shrink(),
                                      ),
                                      const SizedBox(height: 16),

                                      // Enhanced KTP Upload
                                      const Text(
                                        'Foto KTP',
                                        style: TextStyle(
                                          fontFamily: 'Acme',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF2C2C2C),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: _pickKTPImage,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          width: double.infinity,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color:
                                                _ktpImageSelected
                                                    ? Colors.green.withValues(
                                                      alpha: 0.05,
                                                    )
                                                    : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  _ktpImageSelected
                                                      ? Colors.green
                                                      : const Color(
                                                        0xFFF3B950,
                                                      ).withValues(alpha: 0.5),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child:
                                              _ktpImageSelected
                                                  ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color:
                                                            Colors.green[600],
                                                        size: 32,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Foto KTP Berhasil Diambil',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Colors.green[600],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Tap untuk mengambil ulang',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              Colors.green[600],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                  : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .camera_alt_outlined,
                                                        size: 32,
                                                        color: const Color(
                                                          0xFFF3B950,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        'Ambil Foto KTP',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                            0xFF2C2C2C,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const Text(
                                                        'Tap untuk membuka kamera',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Color(
                                                            0xFF999999,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // Enhanced Submit Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: _submitForm,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFF3B950,
                                            ),
                                            foregroundColor: Colors.black87,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 4,
                                            shadowColor: Colors.orange
                                                .withValues(alpha: 0.3),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.send_rounded,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'KIRIM DATA VERIFIKASI',
                                                style: TextStyle(
                                                  fontFamily: 'Acme',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

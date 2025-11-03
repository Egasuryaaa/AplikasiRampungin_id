import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/client_service.dart';
import 'package:rampungin_id_userside/models/user_model.dart';
import 'package:rampungin_id_userside/models/category_model.dart';
import 'package:rampungin_id_userside/client_screens/detail/booking_screen.dart';
import 'package:rampungin_id_userside/client_screens/detail/tukang_detail_screen.dart';

class BrowseTukangScreen extends StatefulWidget {
  final int? kategoriId;
  final String? kategoriNama;

  const BrowseTukangScreen({super.key, this.kategoriId, this.kategoriNama});

  @override
  State<BrowseTukangScreen> createState() => _BrowseTukangScreenState();
}

class _BrowseTukangScreenState extends State<BrowseTukangScreen> {
  final ClientService _clientService = ClientService();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _tukangList = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  // Filters
  int? _selectedKategoriId;
  String? _selectedKota;
  String _selectedStatus = 'tersedia';
  double? _minRating;
  double? _maxTarif;
  String _orderBy = 'rata_rata_rating';
  String _orderDir = 'DESC';

  @override
  void initState() {
    super.initState();
    _selectedKategoriId = widget.kategoriId;
    _loadCategories();
    _loadTukang();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _clientService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      // Silently fail for categories
    }
  }

  Future<void> _loadTukang() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tukangList = await _clientService.browseTukang(
        kategoriId: _selectedKategoriId,
        kota: _selectedKota,
        status: _selectedStatus,
        minRating: _minRating,
        maxTarif: _maxTarif?.toInt(),
        orderBy: _orderBy,
        orderDir: _orderDir,
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _tukangList = tukangList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _FilterDialog(
            selectedKategoriId: _selectedKategoriId,
            selectedKota: _selectedKota,
            selectedStatus: _selectedStatus,
            minRating: _minRating,
            maxTarif: _maxTarif,
            orderBy: _orderBy,
            orderDir: _orderDir,
            categories: _categories,
            onApply: (filters) {
              setState(() {
                _selectedKategoriId = filters['kategoriId'];
                _selectedKota = filters['kota'];
                _selectedStatus = filters['status'];
                _minRating = filters['minRating'];
                _maxTarif = filters['maxTarif'];
                _orderBy = filters['orderBy'];
                _orderDir = filters['orderDir'];
              });
              _loadTukang();
            },
            onReset: () {
              setState(() {
                _selectedKategoriId = null;
                _selectedKota = null;
                _selectedStatus = 'tersedia';
                _minRating = null;
                _maxTarif = null;
                _orderBy = 'rata_rata_rating';
                _orderDir = 'DESC';
              });
              _loadTukang();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3B950),
        title: Text(widget.kategoriNama ?? 'Cari Tukang'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF3B950),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari tukang...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: (value) {
                // Search functionality can be added here
                _loadTukang();
              },
            ),
          ),

          // Active Filters
          if (_selectedKategoriId != null ||
              _selectedKota != null ||
              _minRating != null ||
              _maxTarif != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedKategoriId != null)
                      _buildFilterChip(
                        _categories
                                .firstWhere(
                                  (c) => c.id == _selectedKategoriId,
                                  orElse: () => CategoryModel(nama: 'Kategori'),
                                )
                                .nama ??
                            'Kategori',
                        () {
                          setState(() {
                            _selectedKategoriId = null;
                          });
                          _loadTukang();
                        },
                      ),
                    if (_selectedKota != null)
                      _buildFilterChip(_selectedKota!, () {
                        setState(() {
                          _selectedKota = null;
                        });
                        _loadTukang();
                      }),
                    if (_minRating != null)
                      _buildFilterChip('Rating ≥ $_minRating', () {
                        setState(() {
                          _minRating = null;
                        });
                        _loadTukang();
                      }),
                    if (_maxTarif != null)
                      _buildFilterChip('Tarif ≤ ${_maxTarif!.toInt()}', () {
                        setState(() {
                          _maxTarif = null;
                        });
                        _loadTukang();
                      }),
                  ],
                ),
              ),
            ),

          // Tukang List
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tukangList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      onRefresh: _loadTukang,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tukangList.length,
                        itemBuilder: (context, index) {
                          return _buildTukangCard(_tukangList[index]);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDelete,
        backgroundColor: const Color(0xFFF3B950).withValues(alpha: 0.2),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada tukang ditemukan',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedKategoriId = null;
                _selectedKota = null;
                _minRating = null;
                _maxTarif = null;
              });
              _loadTukang();
            },
            child: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildTukangCard(UserModel tukang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TukangDetailScreen(tukangId: tukang.id!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3B950).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFFF3B950),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tukang.nama ?? 'Nama Tukang',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tukang.namaKategori ?? 'Kategori',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${tukang.rating?.toStringAsFixed(1) ?? '0.0'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${tukang.jumlahPesanan ?? 0} pesanan)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                tukang.statusAktif == 'online'
                                    ? Colors.green[100]
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tukang.statusAktif == 'online'
                                ? 'Tersedia'
                                : 'Tidak Tersedia',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  tukang.statusAktif == 'online'
                                      ? Colors.green[800]
                                      : Colors.grey[800],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        BookingScreen(tukangData: tukang),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3B950),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Pesan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final int? selectedKategoriId;
  final String? selectedKota;
  final String selectedStatus;
  final double? minRating;
  final double? maxTarif;
  final String orderBy;
  final String orderDir;
  final List<CategoryModel> categories;
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onReset;

  const _FilterDialog({
    required this.selectedKategoriId,
    required this.selectedKota,
    required this.selectedStatus,
    required this.minRating,
    required this.maxTarif,
    required this.orderBy,
    required this.orderDir,
    required this.categories,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late int? _kategoriId;
  late String? _kota;
  late String _status;
  late double? _minRating;
  late double? _maxTarif;
  late String _orderBy;
  late String _orderDir;

  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _maxTarifController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _kategoriId = widget.selectedKategoriId;
    _kota = widget.selectedKota;
    _status = widget.selectedStatus;
    _minRating = widget.minRating;
    _maxTarif = widget.maxTarif;
    _orderBy = widget.orderBy;
    _orderDir = widget.orderDir;

    _kotaController.text = _kota ?? '';
    _maxTarifController.text =
        _maxTarif != null ? _maxTarif!.toInt().toString() : '';
  }

  @override
  void dispose() {
    _kotaController.dispose();
    _maxTarifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Urutkan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onReset();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Kategori
                  const Text(
                    'Kategori',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?>(
                    value: _kategoriId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua Kategori'),
                      ),
                      ...widget.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.nama ?? 'Unknown'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _kategoriId = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Kota
                  const Text(
                    'Kota',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _kotaController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Jakarta',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _kota = value.isEmpty ? null : value;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Status
                  const Text(
                    'Status Ketersediaan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'tersedia',
                        child: Text('Tersedia'),
                      ),
                      DropdownMenuItem(
                        value: 'tidak_tersedia',
                        child: Text('Tidak Tersedia'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Rating
                  const Text(
                    'Rating Minimum',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _minRating ?? 0,
                          min: 0,
                          max: 5,
                          divisions: 10,
                          label: _minRating?.toStringAsFixed(1) ?? '0.0',
                          activeColor: const Color(0xFFF3B950),
                          onChanged: (value) {
                            setState(() {
                              _minRating = value == 0 ? null : value;
                            });
                          },
                        ),
                      ),
                      Text(
                        _minRating?.toStringAsFixed(1) ?? '0.0',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Max Tarif
                  const Text(
                    'Tarif Maksimum',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _maxTarifController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 100000',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _maxTarif = value.isEmpty ? null : double.tryParse(value);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Urutkan
                  const Text(
                    'Urutkan Berdasarkan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _orderBy,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'rata_rata_rating',
                        child: Text('Rating'),
                      ),
                      DropdownMenuItem(
                        value: 'tarif_per_jam',
                        child: Text('Tarif'),
                      ),
                      DropdownMenuItem(
                        value: 'pengalaman_tahun',
                        child: Text('Pengalaman'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _orderBy = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // Order Direction
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Tertinggi'),
                          value: 'DESC',
                          groupValue: _orderDir,
                          activeColor: const Color(0xFFF3B950),
                          onChanged: (value) {
                            setState(() {
                              _orderDir = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Terendah'),
                          value: 'ASC',
                          groupValue: _orderDir,
                          activeColor: const Color(0xFFF3B950),
                          onChanged: (value) {
                            setState(() {
                              _orderDir = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply({
                          'kategoriId': _kategoriId,
                          'kota': _kota,
                          'status': _status,
                          'minRating': _minRating,
                          'maxTarif': _maxTarif,
                          'orderBy': _orderBy,
                          'orderDir': _orderDir,
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3B950),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

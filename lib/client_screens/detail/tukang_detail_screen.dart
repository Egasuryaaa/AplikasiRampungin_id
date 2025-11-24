import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/client_service.dart';
import 'package:rampungin_id_userside/models/tukang_detail_model.dart';
import 'package:rampungin_id_userside/models/user_model.dart';
import 'package:rampungin_id_userside/models/rating_model.dart';
import 'package:rampungin_id_userside/client_screens/detail/booking_screen.dart';
import 'package:rampungin_id_userside/core/api_config.dart';
import 'dart:developer' as developer;

class TukangDetailScreen extends StatefulWidget {
  final int tukangId;

  const TukangDetailScreen({super.key, required this.tukangId});

  @override
  State<TukangDetailScreen> createState() => _TukangDetailScreenState();
}

class _TukangDetailScreenState extends State<TukangDetailScreen> {
  final ClientService _clientService = ClientService();

  TukangDetailModel? _tukangData;
  List<RatingModel> _ratings = [];
  bool _isLoading = false;
  bool _isLoadingRatings = false;

  // Base URL untuk foto profil
  final url = ApiConfig.baseUrl;

  Map<int, int> _ratingStats = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

  @override
  void initState() {
    super.initState();
    _loadTukangDetail();
  }

  Future<void> _loadTukangDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      developer.log(
        'Loading tukang detail for ID: ${widget.tukangId}',
        name: 'TukangDetailScreen',
      );

      final tukang = await _clientService.getTukangDetailFull(widget.tukangId);

      developer.log(
        'Tukang loaded successfully: ${tukang.namaLengkap}',
        name: 'TukangDetailScreen',
      );

      // DEBUG: Log semua data untuk memastikan parsing benar
      developer.log(
        'DEBUG - Parsed Data:\n'
        'Nama: ${tukang.namaLengkap}\n'
        'Status: ${tukang.statusKetersediaan}\n'
        'Tarif: ${tukang.tarifPerJam}\n'
        'Pengalaman: ${tukang.pengalamanTahun}\n'
        'Total Pekerjaan: ${tukang.totalPekerjaanSelesai}\n'
        'Bio: ${tukang.bio}\n'
        'Keahlian: ${tukang.keahlian}\n'
        'Rating: ${tukang.rataRataRating}',
        name: 'TukangDetailScreen',
      );

      if (mounted) {
        setState(() {
          _tukangData = tukang;
          _ratings = tukang.ratings ?? [];

          if (tukang.ratingStats != null) {
            _ratingStats = {
              5: tukang.ratingStats!.bintang5 ?? 0,
              4: tukang.ratingStats!.bintang4 ?? 0,
              3: tukang.ratingStats!.bintang3 ?? 0,
              2: tukang.ratingStats!.bintang2 ?? 0,
              1: tukang.ratingStats!.bintang1 ?? 0,
            };
          }

          _isLoading = false;
          _isLoadingRatings = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error loading tukang detail: $e',
        name: 'TukangDetailScreen',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat detail: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Helper method to get photo URL
String? _getPhotoUrl(String? fotoPath) {
  if (fotoPath == null || fotoPath.isEmpty) return null;

  // Jika sudah full URL, langsung return
  if (fotoPath.startsWith('http://') || fotoPath.startsWith('https://')) {
    return fotoPath;
  }

  // Handle path dari API
  if (fotoPath.startsWith('profiles/')) {
    // Format: profiles/foto_profil-xxx.png -> /uploads/profiles/foto_profil-xxx.png
    return '$url/uploads/$fotoPath';
  } else if (fotoPath.startsWith('/uploads/')) {
    // Format: /uploads/profiles/xxx -> full URL
    final cleanPath = fotoPath.startsWith('/uploads') ? fotoPath.substring(1) : fotoPath;
    return '$url/$cleanPath';
  } else {
    // Default case
    return '$url/uploads/$fotoPath';
  }
}

  // Format currency untuk tarif
  String _formatCurrency(double? amount) {
    if (amount == null) return 'Hubungi untuk harga';
    
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Helper untuk parse keahlian dari string ke list
  List<String> _parseKeahlian(List<String>? keahlianList) {
    if (keahlianList == null || keahlianList.isEmpty) return [];
    
    // Jika ada string dengan koma, split menjadi list
    if (keahlianList.length == 1 && keahlianList.first.contains(',')) {
      return keahlianList.first.split(',').map((e) => e.trim()).toList();
    }
    
    return keahlianList;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF6E8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3B950),
          title: const Text('Detail Tukang'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF3B950)),
          ),
        ),
      );
    }

    if (_tukangData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF6E8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3B950),
          title: const Text('Detail Tukang'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Data tukang tidak ditemukan',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3B950),
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final photoUrl = _getPhotoUrl(_tukangData!.fotoProfil);
    final parsedKeahlian = _parseKeahlian(_tukangData!.keahlian);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      body: CustomScrollView(
        slivers: [
          // Header dengan foto profil
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFFF3B950),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF3B950),
                child: Stack(
                  children: [
                    // Foto profil
                    if (photoUrl != null)
                      Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultHeader();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    else
                      _buildDefaultHeader(),
                    
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Konten detail
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informasi utama (nama, kategori, status, rating, tarif)
                _buildMainInfoSection(),
                
                const SizedBox(height: 8),

                // Informasi kontak
                _buildContactInfoSection(),
                
                const SizedBox(height: 8),

                // Pengalaman dan statistik
                _buildExperienceSection(),
                
                const SizedBox(height: 8),

                // Bio (jika ada)
                if (_tukangData!.bio != null && _tukangData!.bio!.isNotEmpty)
                  _buildBioSection(),

                const SizedBox(height: 8),

                // Keahlian (jika ada)
                if (parsedKeahlian.isNotEmpty)
                  _buildSkillsSection(parsedKeahlian),

                const SizedBox(height: 8),

                // Rating dan ulasan
                _buildRatingsSection(),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),

      // Bottom button untuk pesan
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildMainInfoSection() {
    // Debug status ketersediaan
    developer.log(
      'Status Ketersediaan: ${_tukangData!.statusKetersediaan}',
      name: 'TukangDetailScreen',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama dan status ketersediaan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tukangData!.namaLengkap ?? 'Nama Tukang',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Kategori
                    if (_tukangData!.kategori != null && _tukangData!.kategori!.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _tukangData!.kategori!.map((kategori) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3B950).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFF3B950).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              kategori.nama ?? 'Kategori',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B6914),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        'Kategori tidak tersedia',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Status ketersediaan - PERBAIKAN: Gunakan nilai langsung dari API
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _tukangData!.statusKetersediaan == 'tersedia'
                      ? Colors.green[100]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _tukangData!.statusKetersediaan == 'tersedia' 
                      ? 'Tersedia' 
                      : 'Tidak Tersedia',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _tukangData!.statusKetersediaan == 'tersedia'
                        ? Colors.green[800]
                        : Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rating dan jumlah ulasan - PERBAIKAN: Handle null rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 4),
              Text(
                (_tukangData!.rataRataRating ?? 0).toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_tukangData!.ratingStats?.total ?? 0} ulasan)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '${_tukangData!.totalPekerjaanSelesai ?? 0} pesanan',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tarif per jam - PERBAIKAN: Pastikan tarif terlihat
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3B950).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tarif per Jam',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatCurrency(_tukangData!.tarifPerJam),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF3B950),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Kontak',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Nomor telepon
          if (_tukangData!.noTelp != null) ...[
            _buildContactItem(
              Icons.phone,
              _tukangData!.noTelp!,
            ),
            const SizedBox(height: 8),
          ],
          
          // Alamat
          if (_tukangData!.alamat != null) ...[
            _buildContactItem(
              Icons.location_on,
              _tukangData!.alamat!,
              isAddress: true,
            ),
          ],
          
          // Kota dan provinsi
          if (_tukangData!.kota != null || _tukangData!.provinsi != null) ...[
            const SizedBox(height: 8),
            _buildContactItem(
              Icons.place,
              '${_tukangData!.kota ?? ''}${_tukangData!.kota != null && _tukangData!.provinsi != null ? ', ' : ''}${_tukangData!.provinsi ?? ''}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, {bool isAddress = false}) {
    return Row(
      crossAxisAlignment: isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFF3B950),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengalaman',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Tahun pengalaman
          _buildExperienceItem(
            Icons.work,
            '${_tukangData!.pengalamanTahun ?? 0} tahun pengalaman',
          ),
          const SizedBox(height: 8),
          
          // Jumlah pesanan selesai
          _buildExperienceItem(
            Icons.check_circle,
            '${_tukangData!.totalPekerjaanSelesai ?? 0} pesanan diselesaikan',
          ),
          
          // Radius layanan
          if (_tukangData!.radiusLayananKm != null) ...[
            const SizedBox(height: 8),
            _buildExperienceItem(
              Icons.location_on_outlined,
              'Radius layanan: ${_tukangData!.radiusLayananKm} km',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExperienceItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFF3B950),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tentang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _tukangData!.bio!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(List<String> keahlian) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keahlian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keahlian.map((keahlian) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3B950).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  keahlian,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating & Ulasan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Statistik rating per bintang
          ...List.generate(5, (index) {
            int stars = 5 - index;
            int count = _ratingStats[stars] ?? 0;
            int total = _ratings.length;
            double percentage = total > 0 ? (count / total) * 100 : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '$stars',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.amber,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Daftar ulasan
          if (_isLoadingRatings)
            const Center(child: CircularProgressIndicator())
          else if (_ratings.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Belum ada ulasan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ratings.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _buildReviewCard(_ratings[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(RatingModel rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF3B950).withOpacity(0.2),
                child: const Icon(Icons.person, color: Color(0xFFF3B950)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.namaClient ?? 'Client',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < (rating.rating ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(rating.createdAt?.toIso8601String()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rating.ulasan != null && rating.ulasan!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              rating.ulasan!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    // Debug untuk memastikan status ketersediaan
    developer.log(
      'Bottom Button - Status: ${_tukangData!.statusKetersediaan}',
      name: 'TukangDetailScreen',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _tukangData!.statusKetersediaan == 'tersedia'
              ? () {
                  _navigateToBooking();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF3B950),
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _tukangData!.statusKetersediaan == 'tersedia'
                ? 'Pesan Sekarang'
                : 'Tidak Tersedia',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBooking() {
    try {
      developer.log(
        'Preparing booking for tukang ID: ${_tukangData!.id}',
        name: 'TukangDetailScreen',
      );

      int? kategoriId;
      String? kategoriNama;

      if (_tukangData!.kategori != null && _tukangData!.kategori!.isNotEmpty) {
        final firstKategori = _tukangData!.kategori!.first;
        kategoriId = firstKategori.id;
        kategoriNama = firstKategori.nama;

        developer.log(
          'Using kategori: ID=$kategoriId, Nama=$kategoriNama',
          name: 'TukangDetailScreen',
        );
      } else {
        developer.log(
          'WARNING: No kategori available for this tukang!',
          name: 'TukangDetailScreen',
        );
      }

      final userModel = UserModel(
        id: _tukangData!.id,
        nama: _tukangData!.namaLengkap,
        email: _tukangData!.email,
        noHp: _tukangData!.noTelp,
        fotoProfile: _tukangData!.fotoProfil,
        alamat: _tukangData!.alamat,
        idKategori: kategoriId,
        namaKategori: kategoriNama,
        rating: _tukangData!.rataRataRating,
        jumlahPesanan: _tukangData!.totalPekerjaanSelesai,
        tarifPerJam: _tukangData!.tarifPerJam,
      );

      developer.log(
        'UserModel created, navigating to BookingScreen',
        name: 'TukangDetailScreen',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(tukangData: userModel),
        ),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error navigating to booking: $e',
        name: 'TukangDetailScreen',
        error: e,
        stackTrace: stackTrace,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildDefaultHeader() {
    return const Center(
      child: Icon(
        Icons.person,
        size: 100,
        color: Colors.white,
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return date;
    }
  }
}
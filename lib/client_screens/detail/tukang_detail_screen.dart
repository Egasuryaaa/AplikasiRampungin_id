import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/client_service.dart';
import 'package:rampungin_id_userside/models/tukang_detail_model.dart';
import 'package:rampungin_id_userside/models/user_model.dart';
import 'package:rampungin_id_userside/models/rating_model.dart';
import 'package:rampungin_id_userside/client_screens/detail/booking_screen.dart';

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

  // Rating statistics
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
      print('Loading tukang detail for ID: ${widget.tukangId}');

      // Use getTukangDetailFull to get full profile including ratings
      final tukang = await _clientService.getTukangDetailFull(widget.tukangId);

      print('Tukang loaded successfully: ${tukang.namaLengkap}');
      print('Ratings count: ${tukang.ratings?.length ?? 0}');
      print('Rating stats: ${tukang.ratingStats?.total ?? 0}');

      if (mounted) {
        setState(() {
          _tukangData = tukang;
          _ratings = tukang.ratings ?? [];

          // Update rating stats from backend data
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
      print('Error loading tukang detail: $e');
      print('Stack trace: $stackTrace');

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF6E8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3B950),
          title: const Text('Detail Tukang'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_tukangData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF6E8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3B950),
          title: const Text('Detail Tukang'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Data tukang tidak ditemukan'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFFF3B950),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF3B950).withValues(alpha: 0.3),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: Color(0xFFF3B950),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                const SizedBox(height: 4),
                                Text(
                                  (_tukangData!.kategori != null &&
                                          _tukangData!.kategori!.isNotEmpty)
                                      ? (_tukangData!.kategori!.first.nama ??
                                          'Kategori')
                                      : 'Kategori',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _tukangData!.statusKetersediaan == 'tersedia'
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
                                color:
                                    _tukangData!.statusKetersediaan ==
                                            'tersedia'
                                        ? Colors.green[800]
                                        : Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Rating & Stats
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 4),
                          Text(
                            '${_tukangData!.rataRataRating?.toStringAsFixed(1) ?? '0.0'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${_ratings.length} ulasan)',
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

                      // Tarif
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3B950).withValues(alpha: 0.1),
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
                              _tukangData!.tarifPerJam != null
                                  ? 'Rp ${_tukangData!.tarifPerJam!.toStringAsFixed(0)}'
                                  : 'Hubungi untuk harga',
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
                ),

                const SizedBox(height: 8),

                // Contact Info
                Container(
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
                      if (_tukangData!.noTelp != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 20,
                              color: Color(0xFFF3B950),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _tukangData!.noTelp!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (_tukangData!.alamat != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 20,
                              color: Color(0xFFF3B950),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _tukangData!.alamat!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Experience
                Container(
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
                      Row(
                        children: [
                          const Icon(
                            Icons.work,
                            size: 20,
                            color: Color(0xFFF3B950),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_tukangData!.pengalamanTahun ?? 0} tahun pengalaman',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Color(0xFFF3B950),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_tukangData!.totalPekerjaanSelesai ?? 0} pesanan diselesaikan',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Bio Section
                if (_tukangData!.bio != null &&
                    _tukangData!.bio!.isNotEmpty) ...[
                  Container(
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
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Keahlian Section
                if (_tukangData!.keahlian != null &&
                    _tukangData!.keahlian!.isNotEmpty) ...[
                  Container(
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
                          children:
                              _tukangData!.keahlian!.map((keahlian) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF3B950,
                                    ).withValues(alpha: 0.2),
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
                  ),
                  const SizedBox(height: 8),
                ],

                // Rating Breakdown
                Container(
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

                      // Rating Bars
                      ...List.generate(5, (index) {
                        int stars = 5 - index;
                        int count = _ratingStats[stars] ?? 0;
                        int total = _ratings.length;
                        double percentage =
                            total > 0 ? (count / total) * 100 : 0;

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
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
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

                      // Reviews List
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
                ),

                const SizedBox(height: 80), // Space for bottom button
              ],
            ),
          ),
        ],
      ),

      // Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed:
                _tukangData!.statusKetersediaan == 'tersedia'
                    ? () {
                      // Navigate to booking dengan tukang ID dan info
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookingScreen(
                                tukangData: UserModel(
                                  id: _tukangData!.id,
                                  nama: _tukangData!.namaLengkap,
                                  email: _tukangData!.email,
                                  noHp: _tukangData!.noTelp,
                                  fotoProfile: _tukangData!.fotoProfil,
                                  alamat: _tukangData!.alamat,
                                  idKategori:
                                      _tukangData!.kategori != null &&
                                              _tukangData!.kategori!.isNotEmpty
                                          ? _tukangData!.kategori!.first.id
                                          : null,
                                  namaKategori:
                                      _tukangData!.kategori != null &&
                                              _tukangData!.kategori!.isNotEmpty
                                          ? _tukangData!.kategori!.first.nama
                                          : null,
                                  rating: _tukangData!.rataRataRating,
                                  jumlahPesanan:
                                      _tukangData!.totalPekerjaanSelesai,
                                ),
                              ),
                        ),
                      );
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
                backgroundColor: const Color(0xFFF3B950).withValues(alpha: 0.2),
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

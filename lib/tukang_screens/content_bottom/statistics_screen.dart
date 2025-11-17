// File: lib/tukang_screens/content_bottom/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/tukang_service.dart';
import 'package:rampungin_id_userside/models/statistics_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  final TukangService _tukangService = TukangService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF3B950), Color(0xFFE8A63C)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Statistik & Rating',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: const Color(0xFFF3B950),
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: 'Statistik'),
                        Tab(text: 'Rating & Ulasan'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Tab View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStatisticsTab(),
                  _buildRatingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STATISTICS TAB
  Widget _buildStatisticsTab() {
    return FutureBuilder<StatisticsModel>(
      future: _tukangService.getStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFF3B950)),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString(), () {
            setState(() {});
          });
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Tidak ada data statistik'));
        }

        final stats = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saldo Poin
                _buildStatCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Saldo POIN Saat Ini',
                  value: 'Rp ${_formatNumber(stats.saldoPoin)}',
                  color: Colors.green,
                  iconColor: Colors.white,
                ),

                const SizedBox(height: 12),

                // Rating & Pekerjaan
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.star,
                        title: 'Rating Rata-rata',
                        value:
                            stats.rataRataRating?.toStringAsFixed(1) ?? '0.0',
                        color: Colors.orange,
                        iconColor: Colors.white,
                        subtitle: '${stats.totalRating ?? 0} ulasan',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.work,
                        title: 'Pekerjaan Selesai',
                        value: '${stats.totalPekerjaanSelesai ?? 0}',
                        color: Colors.blue,
                        iconColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Transaksi Section
                _buildSectionTitle('Transaksi'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Total Transaksi',
                        '${stats.transaksi?.total ?? 0}',
                        Colors.grey[700]!,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Pending',
                        '${stats.transaksi?.pending ?? 0}',
                        Colors.orange,
                      ),
                      _buildInfoRow(
                        'Diterima',
                        '${stats.transaksi?.diterima ?? 0}',
                        Colors.blue,
                      ),
                      _buildInfoRow(
                        'Dalam Proses',
                        '${stats.transaksi?.dalamProses ?? 0}',
                        Colors.purple,
                      ),
                      _buildInfoRow(
                        'Selesai',
                        '${stats.transaksi?.selesai ?? 0}',
                        Colors.green,
                      ),
                      _buildInfoRow(
                        'Ditolak',
                        '${stats.transaksi?.ditolak ?? 0}',
                        Colors.red,
                      ),
                      _buildInfoRow(
                        'Dibatalkan',
                        '${stats.transaksi?.dibatalkan ?? 0}',
                        Colors.grey,
                      ),
                      const Divider(thickness: 2),
                      _buildInfoRow(
                        'Total Pendapatan',
                        'Rp ${_formatNumber(stats.transaksi?.totalPendapatan)}',
                        const Color(0xFFF3B950),
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Penarikan Section
                _buildSectionTitle('Penarikan Dana'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Total Penarikan',
                        '${stats.penarikan?.total ?? 0}',
                        Colors.grey[700]!,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Pending',
                        '${stats.penarikan?.pending ?? 0}',
                        Colors.orange,
                      ),
                      _buildInfoRow(
                        'Diproses',
                        '${stats.penarikan?.diproses ?? 0}',
                        Colors.blue,
                      ),
                      _buildInfoRow(
                        'Selesai',
                        '${stats.penarikan?.selesai ?? 0}',
                        Colors.green,
                      ),
                      _buildInfoRow(
                        'Ditolak',
                        '${stats.penarikan?.ditolak ?? 0}',
                        Colors.red,
                      ),
                      const Divider(thickness: 2),
                      _buildInfoRow(
                        'Total Ditarik',
                        'Rp ${_formatNumber(stats.penarikan?.totalPenarikan)}',
                        const Color(0xFFF3B950),
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // RATINGS TAB
  Widget _buildRatingsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _tukangService.getRatingsWithStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFF3B950)),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString(), () {
            setState(() {});
          });
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Tidak ada data rating'));
        }

        final data = snapshot.data!;
        final statistik = data['statistik'] as Map<String, dynamic>?;
        final ratingsList = data['ratings'] as List<dynamic>? ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Header
                if (statistik != null)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF3B950), Color(0xFFE8A63C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (statistik['rata_rata'] ?? 0.0).toStringAsFixed(
                                1,
                              ),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${statistik['total_rating'] ?? 0} Ulasan',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Star Distribution
                        _buildStarBar(
                          5,
                          statistik['bintang_5'] ?? 0,
                          statistik['total_rating'] ?? 1,
                        ),
                        _buildStarBar(
                          4,
                          statistik['bintang_4'] ?? 0,
                          statistik['total_rating'] ?? 1,
                        ),
                        _buildStarBar(
                          3,
                          statistik['bintang_3'] ?? 0,
                          statistik['total_rating'] ?? 1,
                        ),
                        _buildStarBar(
                          2,
                          statistik['bintang_2'] ?? 0,
                          statistik['total_rating'] ?? 1,
                        ),
                        _buildStarBar(
                          1,
                          statistik['bintang_1'] ?? 0,
                          statistik['total_rating'] ?? 1,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Ratings List
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Semua Ulasan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (ratingsList.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.rate_review_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada ulasan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ratingsList.length,
                          itemBuilder: (context, index) {
                            final rating =
                                ratingsList[index] as Map<String, dynamic>;
                            return _buildRatingItem(rating);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // SHARED WIDGETS
  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3B950),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color iconColor,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF8B4513),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarBar(int stars, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$stars',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const Icon(Icons.star, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(Map<String, dynamic> rating) {
    final ratingValue = rating['rating'] ?? 0;
    final ulasan = rating['ulasan'] ?? '';
    final namaClient = rating['nama_client'] ?? 'Anonymous';
    final fotoClient = rating['foto_client'];
    final createdAt = rating['created_at'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF3B950),
                backgroundImage:
                    fotoClient != null && fotoClient.isNotEmpty
                        ? NetworkImage(
                            'http://localhost/admintukang/$fotoClient',
                          )
                        : null,
                child: fotoClient == null || fotoClient.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaClient,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < ratingValue
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.orange,
                            size: 16,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          if (ulasan.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              ulasan,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatNumber(double? number) {
    if (number == null) return '0';
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
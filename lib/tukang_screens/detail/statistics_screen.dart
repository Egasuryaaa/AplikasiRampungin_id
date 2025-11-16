import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/tukang_service.dart';
import 'package:rampungin_id_userside/models/statistics_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final TukangService _tukangService = TukangService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3B950),
        title: const Text('Statistik Tukang'),
        elevation: 0,
      ),
      body: FutureBuilder<StatisticsModel>(
        future: _tukangService.getStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF3B950)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat statistik',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3B950),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
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

  String _formatNumber(double? number) {
    if (number == null) return '0';
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

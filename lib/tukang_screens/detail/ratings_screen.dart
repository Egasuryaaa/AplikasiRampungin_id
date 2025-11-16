import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/tukang_service.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  final TukangService _tukangService = TukangService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3B950),
        title: const Text('Rating & Ulasan'),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tukangService.getRatingsWithStats(),
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
                    'Gagal memuat rating',
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
              // Client Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF3B950),
                backgroundImage:
                    fotoClient != null && fotoClient.isNotEmpty
                        ? NetworkImage(
                          'http://localhost/admintukang/$fotoClient',
                        )
                        : null,
                child:
                    fotoClient == null || fotoClient.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
              ),
              const SizedBox(width: 12),

              // Client Name & Rating
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

              // Date
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

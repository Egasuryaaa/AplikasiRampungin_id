import 'package:flutter/material.dart';

class DetailOrder extends StatelessWidget {
  final Map<String, dynamic> technicianData;

  const DetailOrder({super.key, required this.technicianData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 229, 181),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF3B950),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(15, 9, 15, 17),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 7),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 27,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 26),
                    const Expanded(
                      child: Text(
                        'Detail order',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Koulen',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 19),

                      // Technician Info Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(
                                0xFF9B59B6,
                              ).withValues(alpha:0.1),
                              child: Icon(
                                technicianData['icon'] ?? Icons.person,
                                color: const Color(0xFF9B59B6),
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    technicianData['name'] ?? 'Teknisi',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Catamaran',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    technicianData['specialty'] ?? 'Spesialis',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: 'Catamaran',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    technicianData['price'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontFamily: 'Catamaran',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 19),

                      // Content Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF6E8),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                              offset: Offset(-3, -3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(17),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Catatan
                            _buildDetailRow(
                              icon: Icons.note,
                              label: 'Catatan',
                              value: 'Tambahkan catatan khusus...',
                            ),

                            const SizedBox(height: 20),

                            // Nama
                            _buildDetailRow(
                              icon: Icons.person,
                              label: 'Nama',
                              value: 'John Doe',
                            ),

                            const SizedBox(height: 20),

                            // Alamat pengerjaan
                            _buildDetailRow(
                              icon: Icons.location_on,
                              label: 'Alamat pengerjaan',
                              value: 'Jl. Contoh No. 123, Jakarta Selatan',
                            ),

                            const SizedBox(height: 20),

                            // No. Telephone
                            _buildDetailRow(
                              icon: Icons.phone,
                              label: 'No. Telephone',
                              value: '+62 812 3456 7890',
                            ),

                            const SizedBox(height: 20),

                            // Deskripsi job
                            _buildDetailRow(
                              icon: Icons.work,
                              label: 'Deskripsi job',
                              value:
                                  'Perbaikan ${technicianData['specialty']?.toString().toLowerCase() ?? 'peralatan elektronik'}.',
                            ),

                            const SizedBox(height: 30),

                            // Total harga
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3B950).withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Total harga:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      fontFamily: 'Catamaran',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _calculateTotalPrice(
                                      technicianData['price'],
                                    ),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Catamaran',
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Tombol Kembali & Pesan Sekarang
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF9B59B6),
                                ),
                              ),
                              child: const Text(
                                'Kembali',
                                style: TextStyle(
                                  color: Color(0xFF9B59B6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _handleOrderNow(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9B59B6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Pesan Sekarang',
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOrderNow(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pesanan Dikirim'),
            content: const Text(
              'Pesanan Anda berhasil dikirim. Teknisi akan segera menghubungi Anda.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B59B6),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.black54),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Koulen',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  fontFamily: 'Catamaran',
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _calculateTotalPrice(String? priceText) {
    if (priceText == null) return 'Rp 0';

    // Simple calculation based on price text
    if (priceText.contains('Rp 100.000')) {
      return 'Rp 100.000';
    } else if (priceText.contains('Rp 120.000')) {
      return 'Rp 120.000';
    } else if (priceText.contains('Rp 110.000')) {
      return 'Rp 110.000';
    } else if (priceText.contains('Rp 150.000')) {
      return 'Rp 150.000';
    } else if (priceText.contains('Rp 130.000')) {
      return 'Rp 130.000';
    } else if (priceText.contains('Rp 140.000')) {
      return 'Rp 140.000';
    } else if (priceText.contains('Rp 135.000')) {
      return 'Rp 135.000';
    } else if (priceText.contains('Rp 125.000')) {
      return 'Rp 125.000';
    } else if (priceText.contains('Rp 200.000')) {
      return 'Rp 200.000';
    } else if (priceText.contains('Rp 110.000')) {
      return 'Rp 110.000';
    } else if (priceText.contains('Rp 95.000')) {
      return 'Rp 95.000';
    } else if (priceText.contains('Rp 80.000')) {
      return 'Rp 80.000';
    } else if (priceText.contains('Rp 75.000')) {
      return 'Rp 75.000';
    } else if (priceText.contains('Rp 90.000')) {
      return 'Rp 90.000';
    } else {
      return priceText;
    }
  }
}

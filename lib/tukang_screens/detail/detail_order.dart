import 'package:flutter/material.dart';

class DetailOrder extends StatelessWidget {
  const DetailOrder({super. key}) ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
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
                              value: 'Perbaikan instalasi listrik rumah, ganti saklar dan stop kontak di ruang tamu dan kamar tidur.',
                            ),

                            const SizedBox(height: 30),

                            // Total harga
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3B950).withValues( alpha:0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                'Total harga: Rp 750.000',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Catamaran',
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // TERIMA Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle accept action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3B950),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'TERIMA',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Koulen',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      // TOLAK Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle reject action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE3E3E3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'TOLAK',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Koulen',
                              color: Colors.black,
                            ),
                          ),
                        ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.black54,
        ),
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
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
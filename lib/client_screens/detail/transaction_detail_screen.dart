import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/client_service.dart';
import 'package:rampungin_id_userside/models/transaction_model.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final ClientService _clientService = ClientService();
  TransactionModel? _transaction;
  bool _isLoading = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetail();
  }

  Future<void> _loadTransactionDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transaction = await _clientService.getTransactionDetail(
        widget.transactionId,
      );

      if (mounted) {
        setState(() {
          _transaction = transaction;
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
            content: Text('Gagal memuat detail transaksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelTransaction() async {
    final TextEditingController alasanController = TextEditingController();

    final alasan = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Batalkan Pesanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
              const SizedBox(height: 16),
              TextField(
                controller: alasanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alasan Pembatalan',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () {
                if (alasanController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alasan pembatalan harus diisi'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, alasanController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (alasan != null && alasan.isNotEmpty) {
      setState(() {
        _isCancelling = true;
      });

      try {
        await _clientService.cancelTransaction(widget.transactionId, alasan);

        if (mounted) {
          setState(() {
            _isCancelling = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dibatalkan'),
              backgroundColor: Colors.green,
            ),
          );

          // Reload detail
          _loadTransactionDetail();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isCancelling = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membatalkan pesanan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _submitRating() {
    showDialog(
      context: context,
      builder: (context) {
        int rating = 5;
        final TextEditingController ulasanController = TextEditingController();

        return AlertDialog(
          title: const Text('Beri Rating'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Rating'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFF3B950),
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ulasanController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Ulasan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                // Close the dialog first
                navigator.pop();

                try {
                  await _clientService.submitRating(
                    transaksiId: widget.transactionId,
                    rating: rating,
                    ulasan: ulasanController.text,
                  );

                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Rating berhasil dikirim'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Reload the transaction details to show updated rating
                  _loadTransactionDetail();
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengirim rating: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3B950),
              ),
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'diterima':
      case 'accepted':
        return Colors.blue;
      case 'dalam_proses':
      case 'in_progress':
        return Colors.purple;
      case 'selesai':
      case 'completed':
        return Colors.green;
      case 'dibatalkan':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'diterima':
      case 'accepted':
        return 'Diterima';
      case 'dalam_proses':
      case 'in_progress':
        return 'Dalam Proses';
      case 'selesai':
      case 'completed':
        return 'Selesai';
      case 'dibatalkan':
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status ?? 'Unknown';
    }
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3B950),
        title: const Text('Detail Transaksi'),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _transaction == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_transaction!.statusPesanan),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getStatusText(_transaction!.statusPesanan),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pesanan #${_transaction!.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tukang Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Tukang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            'Nama',
                            _transaction!.namaTukang ?? 'N/A',
                            icon: Icons.person,
                          ),
                          _buildInfoRow(
                            'Kontak',
                            _transaction!.noHpTukang ?? 'N/A',
                            icon: Icons.phone,
                          ),
                          _buildInfoRow(
                            'Kategori',
                            _transaction!.namaKategori ?? 'N/A',
                            icon: Icons.category,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Detail Pekerjaan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Pekerjaan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            'Deskripsi',
                            _transaction!.deskripsiPekerjaan ?? 'N/A',
                            icon: Icons.description,
                          ),
                          _buildInfoRow(
                            'Lokasi',
                            _transaction!.alamatPekerjaan ?? 'N/A',
                            icon: Icons.location_on,
                          ),
                          _buildInfoRow(
                            'Tanggal',
                            _transaction!.tanggalPekerjaan ?? 'N/A',
                            icon: Icons.calendar_today,
                          ),
                          _buildInfoRow(
                            'Waktu',
                            _transaction!.waktuPekerjaan ?? 'N/A',
                            icon: Icons.access_time,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Informasi Pembayaran
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            'Metode',
                            _transaction!.metodePembayaran?.toUpperCase() ??
                                'N/A',
                            icon: Icons.payment,
                          ),
                          _buildInfoRow(
                            'Harga Penawaran',
                            'Rp ${_transaction!.hargaPenawaran?.toStringAsFixed(0) ?? 'N/A'}',
                            icon: Icons.money,
                          ),
                          if (_transaction!.hargaAkhir != null)
                            _buildInfoRow(
                              'Harga Akhir',
                              'Rp ${_transaction!.hargaAkhir?.toStringAsFixed(0) ?? 'N/A'}',
                              icon: Icons.check_circle,
                            ),
                        ],
                      ),
                    ),

                    if (_transaction!.alasanPembatalan != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Alasan Pembatalan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_transaction!.alasanPembatalan ?? ''),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action Buttons
                    if (_transaction!.statusPesanan == 'pending' ||
                        _transaction!.statusPesanan == 'diterima')
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isCancelling ? null : _cancelTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isCancelling
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Batalkan Pesanan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),

                    if (_transaction!.statusPesanan == 'selesai' ||
                        _transaction!.statusPesanan == 'completed')
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitRating,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3B950),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Beri Rating',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
    );
  }
}

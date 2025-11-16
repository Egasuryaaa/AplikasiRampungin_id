import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/tukang_service.dart';
import 'package:rampungin_id_userside/models/transaction_model.dart';

class TukangOrderDetailScreen extends StatefulWidget {
  final int orderId;
  final VoidCallback? onOrderUpdated; // Callback untuk refresh home screen

  const TukangOrderDetailScreen({
    super.key,
    required this.orderId,
    this.onOrderUpdated,
  });

  @override
  State<TukangOrderDetailScreen> createState() =>
      _TukangOrderDetailScreenState();
}

class _TukangOrderDetailScreenState extends State<TukangOrderDetailScreen> {
  final TukangService _tukangService = TukangService();
  TransactionModel? _order;
  bool _isLoading = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final order = await _tukangService.getOrderDetail(widget.orderId);

      if (mounted) {
        setState(() {
          _order = order;
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
            content: Text('Gagal memuat detail pesanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _acceptOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Terima Pesanan'),
            content: const Text(
              'Apakah Anda yakin ingin menerima pesanan ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Ya, Terima'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isProcessing = true;
      });

      try {
        await _tukangService.acceptOrder(widget.orderId);

        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil diterima'),
              backgroundColor: Colors.green,
            ),
          );

          _loadOrderDetail();
          widget.onOrderUpdated?.call(); // Notify parent to refresh
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menerima pesanan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectOrder() async {
    final TextEditingController alasanController = TextEditingController();

    final alasan = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tolak Pesanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Mengapa Anda menolak pesanan ini?'),
              const SizedBox(height: 16),
              TextField(
                controller: alasanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alasan Penolakan',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (alasanController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alasan harus diisi')),
                  );
                  return;
                }
                Navigator.pop(context, alasanController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );

    if (alasan != null && alasan.isNotEmpty) {
      setState(() {
        _isProcessing = true;
      });

      try {
        await _tukangService.rejectOrder(widget.orderId, alasan);

        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil ditolak'),
              backgroundColor: Colors.orange,
            ),
          );

          widget.onOrderUpdated?.call(); // Notify parent to refresh
          Navigator.pop(context); // Close detail screen
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menolak pesanan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _startOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mulai Pekerjaan'),
            content: const Text(
              'Apakah Anda sudah siap memulai pekerjaan ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Belum'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Ya, Mulai'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isProcessing = true;
      });

      try {
        await _tukangService.startOrder(widget.orderId);

        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pekerjaan dimulai'),
              backgroundColor: Colors.blue,
            ),
          );

          _loadOrderDetail();
          widget.onOrderUpdated?.call(); // Notify parent to refresh
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memulai pekerjaan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _completeOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Selesaikan Pekerjaan'),
            content: const Text('Apakah pekerjaan sudah selesai dengan baik?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Belum'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Ya, Selesai'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isProcessing = true;
      });

      try {
        await _tukangService.completeOrder(widget.orderId);

        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pekerjaan selesai!'),
              backgroundColor: Colors.green,
            ),
          );

          _loadOrderDetail();
          widget.onOrderUpdated?.call(); // Notify parent to refresh
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyelesaikan pekerjaan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmTunaiPayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Pembayaran Tunai'),
            content: const Text(
              'Apakah pembayaran tunai sudah diterima dari client?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Belum'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Sudah Diterima'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isProcessing = true;
      });

      try {
        await _tukangService.confirmTunaiPayment(widget.orderId);

        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembayaran tunai dikonfirmasi'),
              backgroundColor: Colors.green,
            ),
          );

          _loadOrderDetail();
          widget.onOrderUpdated?.call(); // Notify parent to refresh
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal konfirmasi pembayaran: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
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

  Widget _buildActionButtons() {
    if (_order == null) return const SizedBox.shrink();

    final status = _order!.statusPesanan?.toLowerCase();

    return Column(
      children: [
        if (status == 'pending') ...[
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _rejectOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Tolak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _acceptOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Terima',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        if (status == 'diterima' || status == 'accepted') ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _startOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mulai Pekerjaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        if (status == 'dalam_proses' || status == 'in_progress') ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _completeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Selesaikan Pekerjaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        if ((status == 'selesai' || status == 'completed') &&
            _order!.metodePembayaran?.toLowerCase() == 'tunai') ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _confirmTunaiPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3B950),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Konfirmasi Pembayaran Tunai',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3B950),
        title: const Text('Detail Pesanan'),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _order == null
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
                        color: _getStatusColor(_order!.statusPesanan),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getStatusText(_order!.statusPesanan),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pesanan #${_order!.id}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Client Info
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
                            'Informasi Client',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            'Nama',
                            _order!.namaClient ?? 'N/A',
                            icon: Icons.person,
                          ),
                          _buildInfoRow(
                            'Kontak',
                            _order!.noHpClient ?? 'N/A',
                            icon: Icons.phone,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Job Details
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
                            'Kategori',
                            _order!.namaKategori ?? 'N/A',
                            icon: Icons.category,
                          ),
                          _buildInfoRow(
                            'Deskripsi',
                            _order!.deskripsiPekerjaan ?? 'N/A',
                            icon: Icons.description,
                          ),
                          _buildInfoRow(
                            'Lokasi',
                            _order!.alamatPekerjaan ?? 'N/A',
                            icon: Icons.location_on,
                          ),
                          _buildInfoRow(
                            'Tanggal',
                            _order!.tanggalPekerjaan ?? 'N/A',
                            icon: Icons.calendar_today,
                          ),
                          _buildInfoRow(
                            'Waktu',
                            _order!.waktuPekerjaan ?? 'N/A',
                            icon: Icons.access_time,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment Info
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
                            _order!.metodePembayaran?.toUpperCase() ?? 'N/A',
                            icon: Icons.payment,
                          ),
                          _buildInfoRow(
                            'Harga Penawaran',
                            'Rp ${_order!.hargaPenawaran?.toStringAsFixed(0) ?? 'N/A'}',
                            icon: Icons.money,
                          ),
                          if (_order!.hargaAkhir != null)
                            _buildInfoRow(
                              'Harga Akhir',
                              'Rp ${_order!.hargaAkhir?.toStringAsFixed(0) ?? 'N/A'}',
                              icon: Icons.check_circle,
                            ),
                        ],
                      ),
                    ),

                    if (_order!.alasanPembatalan != null) ...[
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
                            Text(_order!.alasanPembatalan ?? ''),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action Buttons
                    if (_isProcessing)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildActionButtons(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
    );
  }
}

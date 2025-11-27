// File: lib/client_screens/content_bottom/transaction_list_screen.dart
import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/client_service.dart';
import 'package:rampungin_id_userside/models/transaction_model.dart';
import 'package:rampungin_id_userside/client_screens/detail/transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with AutomaticKeepAliveClientMixin {
  final ClientService _clientService = ClientService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  String? _statusFilter;
  String? _metodePembayaranFilter;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _clientService.getTransactions(
        status: _statusFilter,
        metodePembayaran: _metodePembayaranFilter,
      );

      if (mounted) {
        setState(() {
          _transactions = transactions;
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
            content: Text('Gagal memuat transaksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _statusFilter;
        String? tempMetode = _metodePembayaranFilter;

        return AlertDialog(
          title: const Text('Filter Transaksi'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: tempStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Semua')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'diterima', child: Text('Diterima')),
                      DropdownMenuItem(value: 'dalam_proses', child: Text('Dalam Proses')),
                      DropdownMenuItem(value: 'selesai', child: Text('Selesai')),
                      DropdownMenuItem(value: 'dibatalkan', child: Text('Dibatalkan')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        tempStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: tempMetode,
                    decoration: const InputDecoration(
                      labelText: 'Metode Pembayaran',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Semua')),
                      DropdownMenuItem(value: 'poin', child: Text('POIN')),
                      DropdownMenuItem(value: 'tunai', child: Text('TUNAI')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        tempMetode = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _statusFilter = null;
                  _metodePembayaranFilter = null;
                });
                Navigator.pop(context);
                _loadTransactions();
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _statusFilter = tempStatus;
                  _metodePembayaranFilter = tempMetode;
                });
                Navigator.pop(context);
                _loadTransactions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3B950),
              ),
              child: const Text('Terapkan'),
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
        return Colors.blue;
      case 'dalam_proses':
        return Colors.purple;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
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
        return 'Diterima';
      case 'dalam_proses':
        return 'Dalam Proses';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadTransactions,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _transactions.isEmpty
                        ? _buildEmptyState()
                        : _buildTransactionList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFBB41),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(100)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(25, 12, 25, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: 'KdamThmorPro',
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.filter_list,
                color: Color(0xFFF3B950),
                size: 20,
              ),
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailScreen(
                    transactionId: transaction.id!,
                  ),
                ),
              ).then((_) => _loadTransactions());
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${transaction.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(transaction.statusPesanan),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(transaction.statusPesanan),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.deskripsiPekerjaan ?? 'Layanan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tukang: ${transaction.namaTukang ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            transaction.tanggalPekerjaan ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            transaction.waktuPekerjaan ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
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
                          color: transaction.metodePembayaran == 'poin'
                              ? Colors.blue[100]
                              : Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transaction.metodePembayaran?.toUpperCase() ?? 'N/A',
                          style: TextStyle(
                            color: transaction.metodePembayaran == 'poin'
                                ? Colors.blue[800]
                                : Colors.green[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Rp ${(transaction.hargaAkhir ?? transaction.hargaPenawaran ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
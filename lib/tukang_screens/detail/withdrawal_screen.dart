import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/tukang_service.dart';
import 'package:rampungin_id_userside/models/withdrawal_model.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen>
    with SingleTickerProviderStateMixin {
  final TukangService _tukangService = TukangService();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _nomorRekeningController =
      TextEditingController();
  final TextEditingController _namaBankController = TextEditingController();
  final TextEditingController _atasNamaController = TextEditingController();
  late TabController _tabController;

  bool _isLoading = false;
  bool _isLoadingHistory = false;
  List<WithdrawalModel> _withdrawalHistory = [];
  double _currentBalance = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWithdrawalHistory();
    _loadBalance();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _nomorRekeningController.dispose();
    _namaBankController.dispose();
    _atasNamaController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    try {
      final stats = await _tukangService.getStatistics();
      if (mounted) {
        setState(() {
          _currentBalance = stats.saldoPoin ?? 0;
        });
        print('DEBUG: Saldo Poin loaded: $_currentBalance');
      }
    } catch (e) {
      print('ERROR loading balance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat saldo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadWithdrawalHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history = await _tukangService.getWithdrawalHistory();

      if (mounted) {
        setState(() {
          _withdrawalHistory = history;
          _isLoadingHistory = false;
        });
        print('DEBUG: Loaded ${history.length} withdrawal records');
      }
    } catch (e) {
      print('ERROR loading withdrawal history: $e');
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat riwayat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitWithdrawal() async {
    if (_jumlahController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah penarikan harus diisi')),
      );
      return;
    }

    final jumlah = double.tryParse(_jumlahController.text);
    if (jumlah == null || jumlah <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah penarikan tidak valid')),
      );
      return;
    }

    // Validasi minimum Rp 50.000
    if (jumlah < 50000) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah minimum penarikan adalah Rp 50.000'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (jumlah > _currentBalance) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poin tidak mencukupi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_nomorRekeningController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor rekening harus diisi')),
      );
      return;
    }

    if (_namaBankController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama bank harus diisi')));
      return;
    }

    if (_atasNamaController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama pemilik rekening harus diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _tukangService.requestWithdrawal(
        jumlah: jumlah,
        nomorRekening: _nomorRekeningController.text,
        namaBank: _namaBankController.text,
        namaPemilikRekening: _atasNamaController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _jumlahController.clear();
          _nomorRekeningController.clear();
          _namaBankController.clear();
          _atasNamaController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan withdrawal berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload data
        _loadWithdrawalHistory();
        _loadBalance();

        // Switch to history tab
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim permintaan withdrawal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Menunggu Proses';
      case 'diproses':
        return 'Sedang Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status ?? 'Unknown';
    }
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3B950), Color(0xFFE5A73F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Poin Anda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${_currentBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} Poin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '≈ Rp ${_currentBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Informasi Penarikan',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoPoint('• Minimum penarikan: Rp 50.000'),
                _buildInfoPoint('• Fee: 2% (maksimal Rp 5.000)'),
                _buildInfoPoint('• Proses 1-3 hari kerja'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Form
          const Text(
            'Jumlah Penarikan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _jumlahController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {}); // Refresh untuk update fee calculation
            },
            decoration: InputDecoration(
              prefixText: 'Rp ',
              hintText: 'Min. Rp 50.000',
              helperText: 'Minimum penarikan Rp 50.000',
              helperStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          // Fee Calculation Display
          if (_jumlahController.text.isNotEmpty &&
              double.tryParse(_jumlahController.text) != null &&
              double.parse(_jumlahController.text) >= 50000)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  _buildFeeRow(
                    'Jumlah Penarikan',
                    'Rp ${_formatNumber(double.parse(_jumlahController.text).toInt())}',
                  ),
                  const SizedBox(height: 4),
                  _buildFeeRow(
                    'Biaya Admin (2%)',
                    '- Rp ${_formatNumber(_calculateFee(double.parse(_jumlahController.text)))}',
                    isNegative: true,
                  ),
                  const Divider(height: 16),
                  _buildFeeRow(
                    'Jumlah Diterima',
                    'Rp ${_formatNumber((double.parse(_jumlahController.text) - _calculateFee(double.parse(_jumlahController.text))).toInt())}',
                    isBold: true,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Quick Amount Buttons
          Wrap(
            spacing: 8,
            children: [
              _buildQuickAmountButton(100000),
              _buildQuickAmountButton(500000),
              _buildQuickAmountButton(1000000),
              if (_currentBalance > 0)
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _jumlahController.text =
                          _currentBalance.toInt().toString();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF3B950)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Semua Poin',
                    style: TextStyle(color: Color(0xFFF3B950)),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Informasi Rekening',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _namaBankController,
            decoration: InputDecoration(
              labelText: 'Nama Bank',
              hintText: 'Contoh: BCA, Mandiri, BNI',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _nomorRekeningController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Nomor Rekening',
              hintText: 'Masukkan nomor rekening',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _atasNamaController,
            decoration: InputDecoration(
              labelText: 'Atas Nama',
              hintText: 'Nama pemilik rekening',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitWithdrawal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3B950),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Kirim Permintaan Withdrawal',
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
    );
  }

  Widget _buildQuickAmountButton(int amount) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _jumlahController.text = amount.toString();
        });
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFF3B950)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'Rp ${amount >= 1000000 ? '${amount ~/ 1000000}jt' : '${amount ~/ 1000}k'}',
        style: const TextStyle(color: Color(0xFFF3B950)),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_withdrawalHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat withdrawal',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWithdrawalHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _withdrawalHistory.length,
        itemBuilder: (context, index) {
          final withdrawal = _withdrawalHistory[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Withdrawal #${withdrawal.id}',
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
                          color: _getStatusColor(withdrawal.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(withdrawal.status),
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
                    'Rp ${withdrawal.jumlah?.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '${m[1]}.')}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  if (withdrawal.biayaAdmin != null &&
                      withdrawal.jumlahBersih != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Biaya Admin: Rp ${_formatNumber(withdrawal.biayaAdmin!.toInt())} \u2022 Diterima: Rp ${_formatNumber(withdrawal.jumlahBersih!.toInt())}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                  const Divider(height: 24),
                  _buildInfoRow('Bank', withdrawal.namaBank ?? 'N/A'),
                  const SizedBox(height: 4),
                  _buildInfoRow('Rekening', withdrawal.nomorRekening ?? 'N/A'),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    'Atas Nama',
                    withdrawal.namaPemilikRekening ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    withdrawal.createdAt?.toString().substring(0, 16) ?? 'N/A',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  if (withdrawal.alasanPenolakan != null &&
                      withdrawal.alasanPenolakan!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              withdrawal.alasanPenolakan!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(color: Colors.blue[900], fontSize: 13, height: 1.4),
      ),
    );
  }

  Widget _buildFeeRow(
    String label,
    String value, {
    bool isNegative = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color:
                isNegative
                    ? Colors.red
                    : isBold
                    ? Colors.green[700]
                    : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  int _calculateFee(double amount) {
    final fee = (amount * 0.02).round();
    return fee > 5000 ? 5000 : fee;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3B950),
        title: const Text('Withdrawal'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Request Withdrawal'), Tab(text: 'Riwayat')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRequestTab(), _buildHistoryTab()],
      ),
    );
  }
}

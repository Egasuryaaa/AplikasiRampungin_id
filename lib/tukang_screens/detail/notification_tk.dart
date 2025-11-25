import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:rampungin_id_userside/core/api_client.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notificationtk extends StatefulWidget {
  const Notificationtk({super.key});

  @override
  State<Notificationtk> createState() => _NotificationtkState();
}

class _NotificationtkState extends State<Notificationtk>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _loadNotifications();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _clearReadStatus() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('readNotifications');
  setState(() {
    for (var notif in _notifications) {
      notif['isRead'] = false;
    }
    _unreadCount = _notifications.length;
  });
}


Future<void> _loadNotifications() async {
  _logger.i('🔔 Memulai load notifikasi...');

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final isAuth = await _apiClient.isAuthenticated();
    if (!isAuth) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final response = await _apiClient.get('/api/tukang/notification');
    _logger.i('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List<dynamic> data = jsonResponse['data'] ?? [];

        // Ambil notifikasi yang sudah dibaca dari SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final readList = prefs.getStringList('readNotifications') ?? [];

        _notifications = data.map((notif) {
          final timestamp = notif['timestamp']?.toString() ?? '';
          return {
            'type': notif['type'] ?? '',
            'title': notif['title'] ?? '',
            'message': notif['message'] ?? '',
            'timestamp': timestamp,
            'data': notif['data'] ?? {},
            'isRead': readList.contains(timestamp),
          };
        }).toList();

        setState(() {
          _unreadCount = _notifications.where((n) => !n['isRead']).length;
          _isLoading = false;
        });

        _logger.i('✅ State updated: ${_notifications.length} notifikasi, $_unreadCount unread');
      } else {
        throw Exception(jsonResponse['message'] ?? 'Gagal mengambil notifikasi');
      }
    } else if (response.statusCode == 401) {
      _logger.e('❌ Token expired/invalid (401)');
      await _apiClient.removeToken();
      throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
    } else if (response.statusCode == 404) {
      _logger.w('⚠️ Endpoint tidak ditemukan (404)');
      throw Exception('Endpoint notifikasi tidak ditemukan. Hubungi administrator.');
    } else {
      _logger.e('❌ Error ${response.statusCode}: ${response.body}');
      throw Exception('Gagal mengambil notifikasi. Status: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    _logger.e('❌ Exception saat load notifikasi: $e');
    _logger.e('Stack trace: $stackTrace');

    setState(() {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
    });
  }
}


  void _markAsRead(int index) async {
    final notif = _notifications[index];
    final timestamp = notif['timestamp']?.toString();

    setState(() {
      _notifications[index]['isRead'] = true;
      _unreadCount = _notifications.where((n) => !n['isRead']).length;
    });

    if (timestamp != null && timestamp.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final readList = prefs.getStringList('readNotifications') ?? [];
      if (!readList.contains(timestamp)) {
        readList.add(timestamp);
        await prefs.setStringList('readNotifications', readList);
      }
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notif in _notifications) {
        notif['isRead'] = true;
      }
      _unreadCount = 0;
    });
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    final type = notification['type'];

    switch (type) {
      case 'order_baru':
        _showOrderDialog(notification);
        break;
      case 'transaksi_update':
        _showTransactionUpdateDialog(notification);
        break;
      case 'penarikan':
        _showWithdrawalDialog(notification);
        break;
      default:
        _showGenericDialog(notification);
    }
  }

  void _showOrderDialog(Map<String, dynamic> notification) {
    final data = notification['data'] as Map<String, dynamic>? ?? {};

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.work_outline,
                  color: Color(0xFFF3B950),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Detail Order Baru')),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogDetailRow(
                    'Nomor Pesanan',
                    data['nomor_pesanan']?.toString() ?? '-',
                  ),
                  _buildDialogDetailRow(
                    'Client',
                    data['client_nama']?.toString() ?? '-',
                  ),
                  _buildDialogDetailRow(
                    'Kategori',
                    data['kategori']?.toString() ?? '-',
                  ),
                  _buildDialogDetailRow(
                    'Tanggal',
                    _formatDate(data['tanggal_jadwal']),
                  ),
                  _buildDialogDetailRow(
                    'Waktu',
                    data['waktu_jadwal']?.toString() ?? '-',
                  ),
                  _buildDialogDetailRow(
                    'Total Biaya',
                    'Rp ${_formatCurrency(data['total_biaya'])}',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Tutup',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigasi ke halaman detail order
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3B950),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Lihat Detail'),
              ),
            ],
          ),
    );
  }

  void _showTransactionUpdateDialog(Map<String, dynamic> notification) {
    final data = notification['data'] as Map<String, dynamic>? ?? {};
    final status = data['status']?.toString() ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  status == 'selesai' ? Icons.check_circle : Icons.info,
                  color: status == 'selesai' ? Colors.green : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Update Transaksi')),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notification['message'] ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                _buildDialogDetailRow(
                  'Nomor Pesanan',
                  data['nomor_pesanan']?.toString() ?? '-',
                ),
                _buildDialogDetailRow(
                  'Client',
                  data['client_nama']?.toString() ?? '-',
                ),
                _buildDialogDetailRow('Status', status.toUpperCase()),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3B950),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showWithdrawalDialog(Map<String, dynamic> notification) {
    final data = notification['data'] as Map<String, dynamic>? ?? {};
    final status = data['status']?.toString() ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  status == 'selesai' ? Icons.check_circle : Icons.info,
                  color: status == 'selesai' ? Colors.green : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Info Penarikan')),
              ],
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notification['message'] ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                _buildDialogDetailRow(
                  'Jumlah',
                  'Rp ${_formatCurrency(data['jumlah'])}',
                ),
                _buildDialogDetailRow(
                  'Diterima',
                  'Rp ${_formatCurrency(data['jumlah_bersih'])}',
                  isHighlight: true,
                ),
                _buildDialogDetailRow(
                  'Bank',
                  data['nama_bank']?.toString() ?? '-',
                ),
                _buildDialogDetailRow('Status', status.toUpperCase()),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3B950),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showGenericDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(notification['title'] ?? 'Notifikasi'),
            content: Text(notification['message'] ?? ''),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3B950),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildDialogDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: isHighlight ? Colors.green.shade700 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    final number = amount is String ? int.tryParse(amount) ?? 0 : amount;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date.toString();
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '-';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit yang lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return timestamp;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order_baru':
        return Icons.work_outline;
      case 'transaksi_update':
        return Icons.update;
      case 'penarikan':
        return Icons.account_balance_wallet;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order_baru':
        return const Color(0xFFF3B950);
      case 'transaksi_update':
        return Colors.blue;
      case 'penarikan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    bool isRead = notification['isRead'] ?? false;
    final type = notification['type'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isRead ? Colors.white : const Color(0xFFFFF9E6),
        border: Border.all(
          color:
              isRead
                  ? Colors.grey.withOpacity(0.2)
                  : const Color(0xFFF3B950).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _markAsRead(index);
            _handleNotificationAction(notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getNotificationColor(type),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: _getNotificationColor(type).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getNotificationIcon(type),
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'] ?? 'Notifikasi',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3B950),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'BARU',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(notification['timestamp']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notification['message'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF3B950).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: Color(0xFFF3B950),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Notifikasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Terjadi Kesalahan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage ?? 'Gagal memuat notifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3B950),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tambahan: Tombol debug untuk cek detail error
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Detail Error'),
                      content: SingleChildScrollView(
                        child: Text(_errorMessage ?? 'No error details'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
              );
            },
            child: const Text('Lihat Detail Error'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E4BC),
      body: Column(
        children: [
          // Header Section
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
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
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Notifikasi',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (_unreadCount > 0)
                            GestureDetector(
                              onTap: _markAllAsRead,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Tandai Dibaca',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _unreadCount > 0
                                  ? '$_unreadCount notifikasi baru'
                                  : 'Tidak ada notifikasi baru',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF3B950),
                      ),
                    )
                    : _errorMessage != null
                    ? _buildErrorState()
                    : _notifications.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: const Color(0xFFF3B950),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationCard(
                                _notifications[index],
                                index,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

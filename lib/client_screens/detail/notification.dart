import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:rampungin_id_userside/core/api_config.dart';
import 'package:rampungin_id_userside/core/api_client.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ApiClient _apiClient = ApiClient(); // Use ApiClient instance

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  Set<String> _readNotifications = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _loadReadNotifications();
    _loadNotifications();
  }

  /// Load read notification IDs from SharedPreferences
  Future<void> _loadReadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readList = prefs.getStringList('read_notifications') ?? [];
      setState(() {
        _readNotifications = readList.toSet();
      });
      log('📖 Loaded ${_readNotifications.length} read notifications');
    } catch (e) {
      log('⚠️ Failed to load read notifications: $e');
    }
  }

  /// Save read notification IDs to SharedPreferences
  Future<void> _saveReadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_notifications', _readNotifications.toList());
      log('💾 Saved ${_readNotifications.length} read notifications');
    } catch (e) {
      log('⚠️ Failed to save read notifications: $e');
    }
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

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check authentication first
      final isAuth = await _apiClient.isAuthenticated();
      log('🔐 Is Authenticated: $isAuth');

      if (!isAuth) {
        _handleUnauthenticated('Sesi Anda telah berakhir. Silakan login kembali.');
        return;
      }

      // Get token for debugging
      final token = await _apiClient.getToken();
      log('🎫 Token exists: ${token != null}');
      if (token != null) {
        log('🎫 Token length: ${token.length}');
        log('🎫 Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      }

      // Make API request using ApiClient
      log('📡 Making GET request to: /api/client/notification');
      log('📡 Full URL: ${ApiConfig.getFullUrl('/api/client/notification')}');
      
      final response = await _apiClient.get(
        '/api/client/notification',
        requiresAuth: true,
      );

      log('✅ Response status: ${response.statusCode}');
      log('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'] ?? [];

          log('📋 Received ${data.length} notifications');

          setState(() {
            _notifications = data.map((notif) {
              // Generate unique ID for each notification
              final notifId = _generateNotificationId(notif);
              final isRead = _readNotifications.contains(notifId);
              
              return {
                'id': notifId,
                'type': notif['type'] ?? 'general',
                'title': notif['title'] ?? 'Notifikasi',
                'message': notif['message'] ?? '',
                'timestamp': notif['timestamp'] ?? DateTime.now().toIso8601String(),
                'data': notif['data'] ?? {},
                'isRead': isRead,
              };
            }).toList();

            _unreadCount = _notifications.where((n) => !n['isRead']).length;
            _isLoading = false;
          });

          log('✅ Notifications loaded successfully');
        } else {
          throw Exception(
            jsonResponse['message'] ?? 'Gagal mengambil notifikasi',
          );
        }
      } else if (response.statusCode == 401) {
        log('🚫 Unauthorized - Token expired or invalid');
        _handleUnauthenticated('Sesi Anda telah berakhir. Silakan login kembali.');
      } else {
        throw Exception(
          'Gagal mengambil notifikasi. Status: ${response.statusCode}\nResponse: ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      log('❌ Error loading notifications: $e');
      log('📍 Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _errorMessage = _getUserFriendlyError(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  /// Handle unauthenticated state
  void _handleUnauthenticated(String message) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });

    // Show dialog and redirect to login
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text('Sesi Berakhir')),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Clear token
                await _apiClient.removeToken();
                
                if (!mounted) return;
                
                // Close dialog and navigate to login
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3B950),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Login Kembali'),
            ),
          ],
        ),
      );
    });
  }

  /// Convert technical error to user-friendly message
  String _getUserFriendlyError(String error) {
    if (error.contains('SocketException') || error.contains('Failed host lookup')) {
      return 'Tidak dapat terhubung ke server.\nPeriksa koneksi internet Anda.';
    } else if (error.contains('TimeoutException')) {
      return 'Koneksi timeout.\nSilakan coba lagi.';
    } else if (error.contains('401')) {
      return 'Sesi Anda telah berakhir.\nSilakan login kembali.';
    } else if (error.contains('404')) {
      return 'Endpoint tidak ditemukan.\nHubungi administrator.';
    } else if (error.contains('500')) {
      return 'Terjadi kesalahan server.\nSilakan coba lagi nanti.';
    }
    return error;
  }

  /// Generate unique ID for notification
  String _generateNotificationId(Map<String, dynamic> notif) {
    final type = notif['type'] ?? 'general';
    final timestamp = notif['timestamp'] ?? '';
    final data = notif['data'] ?? {};
    
    // Create unique ID based on type and data
    if (type == 'transaksi') {
      return 'transaksi_${data['transaksi_id']}_${data['status']}';
    } else if (type == 'topup') {
      return 'topup_${data['topup_id']}_${data['status']}';
    } else {
      return '${type}_${timestamp}';
    }
  }

  void _markAsRead(int index) {
    final notifId = _notifications[index]['id'] as String;
    
    setState(() {
      _notifications[index]['isRead'] = true;
      _readNotifications.add(notifId);
      _unreadCount = _notifications.where((n) => !n['isRead']).length;
    });
    
    // Save to persistent storage
    _saveReadNotifications();
  }

  void _markAllAsRead() {
    setState(() {
      for (var notif in _notifications) {
        notif['isRead'] = true;
        _readNotifications.add(notif['id'] as String);
      }
      _unreadCount = 0;
    });
    
    // Save to persistent storage
    _saveReadNotifications();
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    final type = notification['type'];

    switch (type) {
      case 'transaksi':
        _showTransactionDialog(notification);
        break;
      case 'topup':
        _showTopupDialog(notification);
        break;
      default:
        _showGenericDialog(notification);
    }
  }

  void _showTransactionDialog(Map<String, dynamic> notification) {
    final data = notification['data'] ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              _getStatusIcon(data['status']?.toString() ?? ''),
              color: _getStatusColor(data['status']?.toString() ?? ''),
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Detail Transaksi')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
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
                'Tukang',
                data['tukang_nama']?.toString() ?? '-',
              ),
              _buildDialogDetailRow(
                'Status',
                _formatStatus(data['status']?.toString() ?? ''),
                isHighlight: true,
              ),
            ],
          ),
        ),
        actions: [
          if (data['status']?.toString().toLowerCase() == 'selesai') ...[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Nanti',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to rating page
                // Navigator.push(context, MaterialPageRoute(...));
              },
              icon: const Icon(Icons.star, size: 18),
              label: const Text('Beri Rating'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3B950),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ] else ...[
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
        ],
      ),
    );
  }

  void _showTopupDialog(Map<String, dynamic> notification) {
    final data = notification['data'] ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              data['status']?.toString().toLowerCase() == 'berhasil'
                  ? Icons.check_circle
                  : data['status']?.toString().toLowerCase() == 'ditolak'
                      ? Icons.cancel
                      : Icons.info,
              color: data['status']?.toString().toLowerCase() == 'berhasil'
                  ? Colors.green
                  : data['status']?.toString().toLowerCase() == 'ditolak'
                      ? Colors.red
                      : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Info Top-up')),
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
              'Jumlah Top-up',
              'Rp ${_formatCurrency(data['jumlah'] ?? 0)}',
              isHighlight: true,
            ),
            _buildDialogDetailRow(
              'Status',
              _formatStatus(data['status']?.toString() ?? ''),
            ),
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
      builder: (context) => AlertDialog(
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
            width: 110,
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
                color: isHighlight ? const Color(0xFFF3B950) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    final number = amount is String ? int.tryParse(amount) ?? 0 : (amount ?? 0);
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatTimestamp(String timestamp) {
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

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      case 'dibatalkan':
        return 'Dibatalkan';
      case 'berhasil':
        return 'Berhasil';
      case 'pending':
        return 'Menunggu';
      default:
        return status;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'transaksi':
        return Icons.receipt_long;
      case 'topup':
        return Icons.account_balance_wallet;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'transaksi':
        return const Color(0xFFF3B950);
      case 'topup':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get notification card color based on type and status
  Color _getNotificationCardColor(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'general';
    log('Notification type: $type');
    final data = notification['data'] ?? {};
    final status = data['status']?.toString().toLowerCase() ?? '';
    
    // Check if it's a rejected/cancelled notification
    if (status == 'ditolak' || status == 'dibatalkan') {
      return const Color(0xFFFFE6E6); // Light red background
    }
    
    // Check if already read
    final isRead = notification['isRead'] ?? false;
    if (isRead) {
      return Colors.white;
    }
    
    // Unread notifications - yellow background
    return const Color(0xFFFFF9E6);
  }

  /// Get notification border color based on type and status
  Color _getNotificationBorderColor(Map<String, dynamic> notification) {
    final data = notification['data'] ?? {};
    final status = data['status']?.toString().toLowerCase() ?? '';
    final isRead = notification['isRead'] ?? false;
    
    // Check if it's a rejected/cancelled notification
    if (status == 'ditolak' || status == 'dibatalkan') {
      return Colors.red.withOpacity(0.5);
    }
    
    // Normal border colors
    if (isRead) {
      return Colors.grey.withOpacity(0.2);
    }
    
    return const Color(0xFFF3B950).withOpacity(0.5);
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'berhasil':
        return Icons.check_circle;
      case 'ditolak':
      case 'dibatalkan':
        return Icons.cancel;
      case 'pending':
        return Icons.access_time;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'berhasil':
        return Colors.green;
      case 'ditolak':
      case 'dibatalkan':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    bool isRead = notification['isRead'] ?? false;
    final type = notification['type'] ?? 'general';
    final data = notification['data'] ?? {};
    final status = data['status']?.toString().toLowerCase() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _getNotificationCardColor(notification),
        border: Border.all(
          color: _getNotificationBorderColor(notification),
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
                                    color: (status == 'ditolak' || status == 'dibatalkan') 
                                        ? Colors.red 
                                        : const Color(0xFFF3B950),
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
                            _formatTimestamp(notification['timestamp'] ?? ''),
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
                    color: const Color(0x40000000),
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
                      // Top navigation
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

                      // Notification summary
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

          // Notifications List
          Expanded(
            child: _isLoading
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
import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/tukang_service.dart';
import 'package:rampungin_id_userside/services/auth_service.dart';
import 'package:rampungin_id_userside/models/transaction_model.dart';
import 'package:rampungin_id_userside/models/statistics_model.dart';
import 'package:rampungin_id_userside/tukang_screens/form/form_tukang.dart';
import '../detail/tukang_order_detail_screen.dart';
import '../detail/profile.dart';
import '../detail/notification_tk.dart';
import '../../Auth_screens/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final TukangService _tukangService = TukangService();
  final AuthService _authService = AuthService();

  // Data from API
  List<TransactionModel> _pendingOrders = [];
  StatisticsModel? _statistics;
  bool _isLoadingData = true;

  // Availability status (3 categories)
  String _availabilityStatus = 'tersedia'; // 'tersedia', 'sibuk', 'offline'
  bool _isUpdatingAvailability = false;

  // Order filter
  String _selectedFilter =
      'pending'; // pending, diterima, dalam_proses, selesai

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Keluar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFE55353)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Ignore logout errors
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _loadTukangData();
  }

  Future<void> _loadTukangData() async {
    await Future.wait([_loadProfile(), _loadOrders(), _loadStatistics()]);

    if (mounted) {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _tukangService.getProfileFull();
      if (mounted && profile.profilTukang != null) {
        setState(() {
          _availabilityStatus =
              profile.profilTukang!.statusKetersediaan ?? 'tersedia';
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _updateAvailability(String newStatus) async {
    setState(() {
      _isUpdatingAvailability = true;
    });

    try {
      await _tukangService.updateAvailability(newStatus);

      if (mounted) {
        setState(() {
          _availabilityStatus = newStatus;
          _isUpdatingAvailability = false;
        });

        String message;
        Color bgColor;

        switch (newStatus) {
          case 'tersedia':
            message = '✅ Status diubah menjadi Tersedia';
            bgColor = Colors.green;
            break;
          case 'sibuk':
            message = '⏱️ Status diubah menjadi Sibuk';
            bgColor = Colors.orange;
            break;
          case 'offline':
            message = '⏸️ Status diubah menjadi Offline';
            bgColor = Colors.grey;
            break;
          default:
            message = '✅ Status berhasil diubah';
            bgColor = Colors.blue;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: bgColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdatingAvailability = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal mengubah status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _tukangService.getOrders(status: _selectedFilter);
      if (mounted) {
        setState(() {
          _pendingOrders = orders;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  void _refreshOrders() {
    setState(() {
      _isLoadingData = true;
    });
    _loadOrders().then((_) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    });
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _tukangService.getStatistics();
      if (mounted) {
        setState(() {
          _statistics = stats;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    if (!mounted) return;
    _pulseController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Order action handlers
  Future<void> _acceptOrder(int orderId) async {
    try {
      await _tukangService.acceptOrder(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pesanan berhasil diterima'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menerima pesanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectOrder(int orderId) async {
    // Show dialog untuk input alasan
    final TextEditingController reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tolak Pesanan'),
            content: TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Penolakan',
                hintText: 'Masukkan alasan penolakan...',
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alasan tidak boleh kosong'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Tolak'),
              ),
            ],
          ),
    );

    if (result == true && reasonController.text.trim().isNotEmpty) {
      try {
        await _tukangService.rejectOrder(orderId, reasonController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Pesanan berhasil ditolak'),
              backgroundColor: Colors.orange,
            ),
          );
          _refreshOrders();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Gagal menolak pesanan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _startOrder(int orderId) async {
    try {
      await _tukangService.startOrder(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pekerjaan dimulai'),
            backgroundColor: Colors.blue,
          ),
        );
        _refreshOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal memulai pekerjaan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeOrder(int orderId) async {
    try {
      await _tukangService.completeOrder(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pekerjaan selesai'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyelesaikan pekerjaan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmTunaiPayment(int orderId) async {
    try {
      await _tukangService.confirmTunaiPayment(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pembayaran tunai dikonfirmasi'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal konfirmasi pembayaran: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStaticCard({required Widget child, required double delay}) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: child),
    );
  }

  // Availability helper methods
  Color _getAvailabilityColor() {
    switch (_availabilityStatus) {
      case 'tersedia':
        return Colors.green;
      case 'sibuk':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getAvailabilityIcon() {
    switch (_availabilityStatus) {
      case 'tersedia':
        return Icons.check_circle;
      case 'sibuk':
        return Icons.access_time;
      case 'offline':
        return Icons.pause_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getAvailabilityText() {
    switch (_availabilityStatus) {
      case 'tersedia':
        return 'Tersedia';
      case 'sibuk':
        return 'Sibuk';
      case 'offline':
        return 'Offline';
      default:
        return 'Unknown';
    }
  }

  void _showAvailabilityMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ubah Status Ketersediaan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildAvailabilityOption(
                  'tersedia',
                  'Tersedia',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildAvailabilityOption(
                  'sibuk',
                  'Sibuk',
                  Icons.access_time,
                  Colors.orange,
                ),
                _buildAvailabilityOption(
                  'offline',
                  'Offline',
                  Icons.pause_circle,
                  Colors.grey,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildAvailabilityOption(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _availabilityStatus == value;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: color) : null,
      onTap: () {
        Navigator.pop(context);
        if (_availabilityStatus != value) {
          _updateAvailability(value);
        }
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
          _isLoadingData = true;
        });
        _loadOrders().then((_) {
          if (mounted) {
            setState(() {
              _isLoadingData = false;
            });
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [Color(0xFFF3B950), Color(0xFFE8A63C)],
                  )
                  : null,
          color: isSelected ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFFF3B950).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildJobOrderItem(TransactionModel order) {
    // Determine status color and text
    Color statusColor;
    String statusText;

    switch (order.statusPesanan?.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case 'diterima':
        statusColor = Colors.blue;
        statusText = 'Diterima';
        break;
      case 'dalam_proses':
        statusColor = Colors.purple;
        statusText = 'Dikerjakan';
        break;
      case 'selesai':
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      default:
        statusColor = Colors.grey;
        statusText = order.statusPesanan ?? 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Info
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TukangOrderDetailScreen(
                        orderId: order.id!,
                        onOrderUpdated:
                            _refreshOrders, // Refresh saat order diupdate
                      ),
                ),
              );
              // Refresh juga saat kembali dari detail screen
              _refreshOrders();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B4513), Color(0xFF7A3E0F)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.judulLayanan ?? 'Pesanan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.namaClient ?? 'Client',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${order.hargaAkhir?.toStringAsFixed(0) ?? '0'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF3B950),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          _buildOrderActionButtons(order),
        ],
      ),
    );
  }

  Widget _buildOrderActionButtons(TransactionModel order) {
    final status = order.statusPesanan?.toLowerCase() ?? '';

    if (status == 'pending') {
      // Terima & Tolak
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _rejectOrder(order.id!),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Tolak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _acceptOrder(order.id!),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Terima'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (status == 'diterima') {
      // Mulai Pekerjaan
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _startOrder(order.id!),
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Mulai Pekerjaan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    } else if (status == 'dalam_proses') {
      // Selesaikan Pekerjaan
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _completeOrder(order.id!),
            icon: const Icon(Icons.check_circle, size: 20),
            label: const Text('Selesaikan Pekerjaan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    } else if (status == 'selesai' &&
        order.metodePembayaran?.toLowerCase() == 'tunai') {
      // Konfirmasi Bayar Tunai (hanya jika belum dikonfirmasi)
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _confirmTunaiPayment(order.id!),
            icon: const Icon(Icons.payments, size: 20),
            label: const Text('Konfirmasi Bayar Tunai'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3B950),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildVerificationCard() {
    return _buildStaticCard(
      delay: 0.3,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 8),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // Add delay to ensure layout is complete
              Future.microtask(() {
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FormTukang()),
                  );
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.verified_user,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verifikasi Tukang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lengkapi verifikasi untuk meningkatkan kepercayaan pelanggan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Verifikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E4BC),
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Enhanced Header Section with Logout Button
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
                              bottomLeft: Radius.circular(100),
                              bottomRight: Radius.circular(100),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x40000000),
                                offset: const Offset(0, 4),
                                blurRadius: 20,
                              ),
                              BoxShadow(
                                color: const Color(
                                  0xFFF3B950,
                                ).withValues(alpha: 0.3),
                                offset: const Offset(0, 8),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),

                                // Enhanced top bar with logout and availability toggle
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Availability Status Selector (3 categories)
                                    InkWell(
                                      onTap:
                                          _isUpdatingAvailability
                                              ? null
                                              : _showAvailabilityMenu,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getAvailabilityColor()
                                              .withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: _getAvailabilityColor(),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getAvailabilityIcon(),
                                              color: _getAvailabilityColor(),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _getAvailabilityText(),
                                              style: TextStyle(
                                                color: _getAvailabilityColor()
                                                    .withValues(alpha: 0.8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: _getAvailabilityColor(),
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Logout Button (moved to right)
                                    GestureDetector(
                                      onTap: _showLogoutDialog,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.logout,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Keluar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Right side buttons
                                    Row(
                                      children: [
                                        // Fixed notification button
                                        AnimatedBuilder(
                                          animation: _pulseAnimation,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale:
                                                  _pulseAnimation.value * 0.1 +
                                                  0.95,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              const Notificationtk(),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.notifications,
                                                    size: 28,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Profile(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color: Color(0xFFF3B950),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 40),

                                // Enhanced welcome text
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback:
                                          (bounds) => LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                            ],
                                          ).createShader(bounds),
                                      child: const Text(
                                        'Selamat datang di Rampungin.id',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          shadows: [
                                            Shadow(
                                              color: Color(0x40000000),
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Text(
                                        'siap kerja hari ini?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Kotak Verifikasi Tukang
                      _buildVerificationCard(),

                      const SizedBox(height: 24),

                      // Enhanced Earnings Card
                      _buildStaticCard(
                        delay: 0.2,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.9),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                offset: const Offset(0, 8),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: const Color(
                                  0xFFF3B950,
                                ).withValues(alpha: 0.1),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF3B950),
                                      Color(0xFFE8A63C),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFF3B950,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Pendapatan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _isLoadingData
                                        ? SizedBox(
                                          height: 22,
                                          child: Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFFF3B950),
                                              ),
                                            ),
                                          ),
                                        )
                                        : Text(
                                          'Rp ${(_statistics?.saldoPoin ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade100,
                                      Colors.orange.shade50,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      // Handle withdrawal action
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.monetization_on,
                                            color: Color(0xFFF3B950),
                                            size: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'Tarik Tunai',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 44),

                      // Enhanced Order Masuk Section
                      _buildStaticCard(
                        delay: 0.4,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              // Enhanced Order Header
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Color(0xFFFAFAFA)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      offset: const Offset(0, -2),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 20,
                                ),
                                child: Column(
                                  children: [
                                    // Title Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF8B4513,
                                            ).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.work_outline,
                                            color: Color(0xFF8B4513),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'ORDER MASUK',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8B4513),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Filter Tabs
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _buildFilterChip('Baru', 'pending'),
                                          const SizedBox(width: 8),
                                          _buildFilterChip(
                                            'Diterima',
                                            'diterima',
                                          ),
                                          const SizedBox(width: 8),
                                          _buildFilterChip(
                                            'Dikerjakan',
                                            'dalam_proses',
                                          ),
                                          const SizedBox(width: 8),
                                          _buildFilterChip(
                                            'Selesai',
                                            'selesai',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Enhanced Order Content
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(25),
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      offset: const Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child:
                                    _isLoadingData
                                        ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: CircularProgressIndicator(
                                              color: Color(0xFFF3B950),
                                            ),
                                          ),
                                        )
                                        : _pendingOrders.isEmpty
                                        ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.inbox_outlined,
                                                  size: 60,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Belum ada order masuk',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        : Column(
                                          children: [
                                            for (
                                              int i = 0;
                                              i < _pendingOrders.length &&
                                                  i < 3;
                                              i++
                                            )
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  bottom:
                                                      i <
                                                                  _pendingOrders
                                                                          .length -
                                                                      1 &&
                                                              i < 2
                                                          ? 12
                                                          : 0,
                                                ),
                                                child: _buildJobOrderItem(
                                                  _pendingOrders[i],
                                                ),
                                              ),
                                            const SizedBox(height: 20),
                                          ],
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ), // Reduced space for bottom navigation
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

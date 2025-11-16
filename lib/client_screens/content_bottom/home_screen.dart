import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/services/client_service.dart';
import 'package:rampungin_id_userside/services/auth_service.dart';
import 'package:rampungin_id_userside/models/user_model.dart';
import 'package:rampungin_id_userside/models/category_model.dart';
import 'package:rampungin_id_userside/models/statistics_model.dart';
import 'package:rampungin_id_userside/client_screens/detail/browse_tukang_screen.dart';
import 'package:rampungin_id_userside/client_screens/detail/tukang_detail_screen.dart';
import 'package:rampungin_id_userside/client_screens/detail/transaction_list_screen.dart';
import 'package:rampungin_id_userside/client_screens/detail/profile_screen.dart';
import 'package:rampungin_id_userside/client_screens/detail/notification.dart';
import 'package:rampungin_id_userside/Auth_screens/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final int _currentIndex = 0;
  final ClientService _clientService = ClientService();
  final AuthService _authService = AuthService();

  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // API Data
  List<UserModel> _allTukangList = [];
  List<CategoryModel> _categoryList = []; // ignore: unused_field
  StatisticsModel? _statistics; // ignore: unused_field
  UserModel? _currentUser;
  int _userPoints = 0; // Poin user
  bool _isLoadingTukang = true;
  bool _isLoadingProfile = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAllData();
  }

  // Load all data from API
  Future<void> _loadAllData() async {
    await Future.wait([
      _loadUserProfile(),
      _loadCategories(),
      _loadTukangList(),
      _loadStatistics(),
    ]);
  }

  // Load current user profile
  Future<void> _loadUserProfile() async {
    try {
      final user = await _authService.getCurrentUser();

      if (mounted) {
        setState(() {
          _currentUser = user;
          // Ambil poin dari user (sudah di-parse di UserModel.saldo)
          _userPoints = (user.saldo ?? 0).toInt();
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  // Load categories
  Future<void> _loadCategories() async {
    try {
      final categories = await _clientService.getCategories();

      if (mounted) {
        setState(() {
          _categoryList = categories;
        });
      }
    } catch (e) {
      // Silently fail, categories are optional
    }
  }

  // Load all tukang from API
  Future<void> _loadTukangList() async {
    try {
      // Browse tukang with status "tersedia" and order by rating
      final tukangList = await _clientService.browseTukang(
        status: 'tersedia',
        orderBy: 'rata_rata_rating',
        orderDir: 'DESC',
        limit: 50,
      );

      if (mounted) {
        setState(() {
          _allTukangList = tukangList;
          _isLoadingTukang = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingTukang = false;
        });
      }
    }
  }

  // Load statistics (for balance)
  Future<void> _loadStatistics() async {
    try {
      final stats = await _clientService.getStatistics();

      if (mounted) {
        setState(() {
          _statistics = stats;
          // Kita tidak perlu _userBalance lagi, karena poin diambil dari user profile
        });
      }
    } catch (e) {
      // Silently fail, balance will show 0
      if (mounted) {
        setState(() {
          // Do nothing, poin sudah di-load dari user profile
        });
      }
    }
  }

  // Group tukang by category - Handle multiple categories per tukang
  Map<String, List<UserModel>> get _techniciansByCategory {
    final Map<String, List<UserModel>> grouped = {};

    for (var tukang in _allTukangList) {
      // Get categories from kategoriList array
      if (tukang.kategoriList != null && tukang.kategoriList!.isNotEmpty) {
        for (var kategoriJson in tukang.kategoriList!) {
          final categoryName = kategoriJson['nama'] as String? ?? 'Lainnya';

          if (!grouped.containsKey(categoryName)) {
            grouped[categoryName] = [];
          }

          // Add tukang to this category if not already added
          if (!grouped[categoryName]!.any((t) => t.id == tukang.id)) {
            grouped[categoryName]!.add(tukang);
          }
        }
      } else {
        // Fallback to single namaKategori if kategoriList is empty
        final category = tukang.namaKategori ?? 'Lainnya';
        if (!grouped.containsKey(category)) {
          grouped[category] = [];
        }
        grouped[category]!.add(tukang);
      }
    }

    return grouped;
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    if (!mounted) return;
    _fadeController.forward();
    _slideController.forward();
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
      backgroundColor: const Color(0xFFFDF6E8),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionListScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFF3B950),
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: const Text(
          'Riwayat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      
    );
  }
 

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFBB41),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(200)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(25, 12, 25, 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 21),
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/img/LogoRampung.png',
                    width: 120,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 23),
                Text(
                  'Selamat Datang ${_currentUser?.nama ?? "Client"}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'KdamThmorPro',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildHeaderIcon(
                  Icons.person_outline,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  ),
                  size: 45,
                ),
                const SizedBox(width: 8),
                _buildHeaderIcon(
                  Icons.notifications_none,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  ),
                  size: 30,
                  iconSize: 20,
                ),
                const SizedBox(width: 8),
                _buildHeaderIcon(
                  Icons.logout,
                  () => _handleLogout(),
                  size: 30,
                  iconSize: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(
    IconData icon,
    VoidCallback onTap, {
    double size = 30,
    double iconSize = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onTap,
          child: Icon(icon, color: const Color(0xFFF3B950), size: iconSize),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    // Show loading indicator while fetching data
    if (_isLoadingTukang) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: CircularProgressIndicator(color: Color(0xFFF3B950)),
        ),
      );
    }

    // Show error message if loading failed
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoadingTukang = true;
                    _errorMessage = null;
                  });
                  _loadTukangList();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3B950),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 22),
          _buildAnimatedCard(_buildBalanceCard(), delay: 0),
          const SizedBox(height: 20),
          _buildAnimatedCard(_buildSearchBar(), delay: 100),

          const SizedBox(height: 31),
          // Kategori Tukang dengan Cards
          ..._buildCategoryTechnicians(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryTechnicians() {
    List<Widget> widgets = [];
    int delay = 200;

    _techniciansByCategory.forEach((category, technicians) {
      widgets.add(
        _buildAnimatedCard(
          _buildCategorySection(category, technicians),
          delay: delay,
        ),
      );
      delay += 100;
    });

    return widgets;
  }

  Widget _buildCategorySection(String category, List<UserModel> technicians) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToCategory(category),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFF3B950),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              return _buildTechnicianCard(technicians[index]);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTechnicianCard(UserModel technician) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetailOrder(technician),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Tukang
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3B950).withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: const Color(0xFFF3B950),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    Text(
                      technician.nama ?? 'Nama Tukang',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${technician.rating?.toStringAsFixed(1) ?? '0.0'} (${technician.jumlahPesanan ?? 0} pesanan)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Status
                    Text(
                      technician.statusAktif == 'tersedia' ||
                              technician.statusAktif == 'online'
                          ? '🟢 Online'
                          : technician.statusAktif == 'sibuk'
                          ? '🟠 Sibuk'
                          : '⚫ Offline',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color:
                            technician.statusAktif == 'tersedia' ||
                                    technician.statusAktif == 'online'
                                ? Colors.green
                                : technician.statusAktif == 'sibuk'
                                ? Colors.orange
                                : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Button Pesan
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => _navigateToDetailOrder(technician),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3B950),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(String categoryName) {
    // Find category by name to get its ID
    final category = _techniciansByCategory.keys.firstWhere(
      (cat) => cat == categoryName,
      orElse: () => categoryName,
    );

    // Navigate to BrowseTukangScreen filtered by this category
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowseTukangScreen(kategoriNama: category),
      ),
    );
  }

  void _navigateToDetailOrder(UserModel technicianData) {
    // Navigate to Tukang Detail Screen instead of direct booking
    if (technicianData.id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => TukangDetailScreen(tukangId: technicianData.id!),
        ),
      );
    }
  }

  Widget _buildAnimatedCard(Widget child, {int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3B950),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo Anda',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  _isLoadingProfile
                      ? const SizedBox(
                        width: 100,
                        height: 24,
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
                        'Rp ${_userPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                ],
              ),
            ],
          ),
          _buildTopUpButton(),
        ],
      ),
    );
  }

  Widget _buildTopUpButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.of(context).pushNamed('/TopUpScreen');
        },
        child: Column(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFFF3B950),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 4),
            const Text(
              'Top up',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 318),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to BrowseTukangScreen with search capability
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BrowseTukangScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text(
                    'Cari tukang disini...',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  // Navigate to BrowseTukangScreen with filters open
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BrowseTukangScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3B950),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Keluar Akun'),
            content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  try {
                    // Call logout API
                    await _authService.logout();
                  } catch (e) {
                    // API error handling - token is still removed by the service
                  }

                  // Navigate to login screen and remove all previous routes
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }
}

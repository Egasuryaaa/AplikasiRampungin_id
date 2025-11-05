import 'package:flutter/material.dart';

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

  //Data ini akan diambil dari database
  List<Map<String, dynamic>> _newOrders = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    //Panggil fungsi untuk fetch data dari database
    _loadNewOrders();
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
    _fadeController.forward();
    _slideController.forward();
  }

  //Ganti dengan fungsi yang mengambil data dari database
  Future<void> _loadNewOrders() async {
    // Simulasi fetch dari database
    // Ganti dengan: await DatabaseService.getNewOrders();

    setState(() {
      // Contoh data - akan diganti dengan data dari database
      _newOrders = [
        // {
        //   'orderId': 'ORD001',
        //   'customerName': 'Budi Santoso',
        //   'serviceType': 'Perbaikan AC',
        //   'location': 'Jl. Malioboro No. 45, Yogyakarta',
        //   'price': 'Rp 150.000',
        //   'time': '5 menit yang lalu',
        //   'isRead': false,
        //   'description': 'AC tidak dingin, perlu dibersihkan',
        // },
      ];

      _unreadCount = _newOrders.where((order) => !order['isRead']).length;
    });
  }

  void _markAsRead(int index) {
    setState(() {
      _newOrders[index]['isRead'] = true;
      _unreadCount = _newOrders.where((order) => !order['isRead']).length;
    });

    //Update status di database
    // await DatabaseService.markOrderAsRead(_newOrders[index]['orderId']);
  }

  void _markAllAsRead() {
    setState(() {
      for (var order in _newOrders) {
        order['isRead'] = true;
      }
      _unreadCount = 0;
    });

    //Update semua status di database
    //await DatabaseService.markAllOrdersAsRead();
  }

  void _acceptOrder(Map<String, dynamic> order) {
    //Implementasi logika menerima orderan
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Terima Orderan?'),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin menerima orderan dari ${order['customerName']}?',
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  //Kirim konfirmasi ke database
                  // await DatabaseService.acceptOrder(order['orderId']);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Orderan berhasil diterima!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Terima'),
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

  Widget _buildOrderNotificationCard(Map<String, dynamic> order, int index) {
    bool isRead = order['isRead'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isRead ? Colors.white : const Color(0xFFFFF9E6),
        border: Border.all(
          color:
              isRead
                  ? Colors.grey.withValues(alpha: 0.2)
                  : const Color(0xFFF3B950).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
          onTap: () => _markAsRead(index),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon + Title + Badge
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF3B950), Color(0xFFE8A63C)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFF3B950,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.work_outline,
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
                              const Text(
                                'Orderan Baru',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
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
                          const SizedBox(height: 2),
                          Text(
                            order['time'] ?? '',
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

                const SizedBox(height: 16),

                // Divider
                Divider(color: Colors.grey.shade300, height: 1),

                const SizedBox(height: 16),

                // Order Details
                _buildDetailRow(
                  Icons.person_outline,
                  'Pelanggan',
                  order['customerName'] ?? '',
                ),
                const SizedBox(height: 12),

                _buildDetailRow(
                  Icons.build_outlined,
                  'Jenis Layanan',
                  order['serviceType'] ?? '',
                ),
                const SizedBox(height: 12),

                _buildDetailRow(
                  Icons.location_on_outlined,
                  'Lokasi',
                  order['location'] ?? '',
                ),
                const SizedBox(height: 12),

                _buildDetailRow(
                  Icons.payments_outlined,
                  'Harga',
                  order['price'] ?? '',
                  valueColor: Colors.green.shade700,
                ),

                if (order['description'] != null &&
                    order['description'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.description_outlined,
                    'Keterangan',
                    order['description'],
                  ),
                ],

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          //Implementasi tolak orderan
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Tolak Orderan?'),
                                  content: const Text(
                                    'Orderan ini akan ditawarkan ke tukang lain.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _newOrders.removeAt(index);
                                          _unreadCount =
                                              _newOrders
                                                  .where((o) => !o['isRead'])
                                                  .length;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Tolak'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        icon: const Icon(Icons.close, size: 20),
                        label: const Text('Tolak'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptOrder(order),
                        icon: const Icon(Icons.check, size: 20),
                        label: const Text('Terima Orderan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
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
              color: const Color(0xFFF3B950).withValues(alpha: 0.1),
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
            'Belum Ada Orderan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orderan baru akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
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
                                color: Colors.white.withValues(alpha: 0.2),
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
                              'Orderan Baru',
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
                                  color: Colors.white.withValues(alpha: 0.2),
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
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.work_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _unreadCount > 0
                                  ? '$_unreadCount orderan baru'
                                  : 'Tidak ada orderan baru',
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

          // Orders List
          Expanded(
            child:
                _newOrders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      onRefresh: _loadNewOrders,
                      color: const Color(0xFFF3B950),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _newOrders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderNotificationCard(
                                _newOrders[index],
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

import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/client_screens/detail/kategoribangunanmaster.dart';
import 'package:rampungin_id_userside/client_screens/detail/detail_order.dart';

class LisrikScreen extends KategoriBangunanMaster {
  const LisrikScreen({super.key});

  @override
  State<LisrikScreen> createState() => _LisrikScreenState();
}

class _LisrikScreenState extends KategoriBangunanMasterState<LisrikScreen> {
  @override
  String getTitle() => 'Elektronik';

  @override
  Color getPrimaryColor() => const Color(0xFFF3B950);

  @override
  IconData getCategoryIcon() => Icons.electrical_services;

  @override
  List<Map<String, dynamic>> getItems() {
    return [
      {
        'name': 'Andi Pratama',
        'description':
            'Service TV & Home Theater • 9 tahun • ⭐ 4.9 (156 review)',
        'icon': Icons.person,
        'specialty': 'Elektronik Entertainment',
        'price': 'Rp 100.000 + sparepart',
        'status': 'online',
        'technicianId': 'tech_elec_001',
      },
    ];
  }

  @override
  void showServiceDetail(Map<String, dynamic> item) {
    // Method tidak digunakan, langsung redirect ke DetailOrder
    _navigateToDetailOrder(item);
  }

  @override
  void onItemPressed(BuildContext context, Map<String, dynamic> item) {
    // Panggil showServiceDetail yang sudah diimplementasikan
    showServiceDetail(item);
  }

  void _navigateToDetailOrder(Map<String, dynamic> technicianData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailOrder(technicianData: technicianData),
      ),
    );
  }
}

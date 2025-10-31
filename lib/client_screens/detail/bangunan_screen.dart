import 'package:flutter/material.dart';
import 'package:rampungin_id_userside/client_screens/detail/kategoribangunanmaster.dart';
import 'package:rampungin_id_userside/client_screens/detail/detail_order.dart';

class BangunanScreen extends KategoriBangunanMaster {
  const BangunanScreen({super.key});

  @override
  State<BangunanScreen> createState() => _BangunanScreenState();
}

class _BangunanScreenState extends KategoriBangunanMasterState<BangunanScreen> {
  @override
  String getTitle() => 'Bangunan';

  @override
  Color getPrimaryColor() => const Color(0xFFF3B950);

  @override
  IconData getCategoryIcon() => Icons.home;

  @override
  List<Map<String, dynamic>> getItems() {
    return [
      {
        'name': 'Budi Santoso',
        'description':
            'Tukang Bangunan • 15 tahun pengalaman • ⭐ 4.8 (127 review)',
        'icon': Icons.person,
        'specialty': 'Renovasi & Bangun Rumah',
        'price': 'Rp 150.000/hari',
        'status': 'online',
        'technicianId': 'tech_build_001',
      },
      {
        'name': 'Agus Wijaya',
        'description': 'Tukang Cat • 10 tahun pengalaman • ⭐ 4.9 (95 review)',
        'icon': Icons.person,
        'specialty': 'Pengecatan Interior & Eksterior',
        'price': 'Rp 120.000/hari',
        'status': 'online',
        'technicianId': 'tech_build_002',
      },
      {
        'name': 'Hendra Kusuma',
        'description': 'Tukang Batu • 12 tahun pengalaman • ⭐ 4.7 (143 review)',
        'icon': Icons.person,
        'specialty': 'Pasang Keramik & Ubin',
        'price': 'Rp 130.000/hari',
        'status': 'online',
        'technicianId': 'tech_build_003',
      },
    ];
  }

  @override
  void showServiceDetail(Map<String, dynamic> item) {
    _navigateToDetailOrder(item);
  }

  @override
  void onItemPressed(BuildContext context, Map<String, dynamic> item) {
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

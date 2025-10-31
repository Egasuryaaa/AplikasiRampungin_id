import 'package:flutter/material.dart';
import 'kategoribangunanmaster.dart';

class KategoriBangunanScreen extends KategoriBangunanMaster {
  const KategoriBangunanScreen({super.key});

  @override
  State<KategoriBangunanMaster> createState() => _KategoriBangunanScreenState();
}

class _KategoriBangunanScreenState
    extends KategoriBangunanMasterState<KategoriBangunanScreen> {
  @override
  String getTitle() => 'Bangunan';

  @override
  Color getPrimaryColor() => Color(0xFFF3B950);

  @override
  IconData getCategoryIcon() => Icons.home_work;

  @override
  List<Map<String, dynamic>> getItems() {
    return [
      {
        'name': 'Elektronik',
        'description': 'Layanan perbaikan dan servis peralatan elektronik.',
        'icon': Icons.electrical_services,
      },
      {
        'name': 'Bangunan',
        'description': 'Layanan perbaikan dan renovasi rumah atau gedung.',
        'icon': Icons.architecture,
      },
      {
        'name': 'Mobil',
        'description': 'Layanan perbaikan dan perawatan kendaraan mobil.',
        'icon': Icons.directions_car,
      },
      {
        'name': 'Cleaning Service',
        'description': 'Layanan kebersihan rumah dan kantor.',
        'icon': Icons.cleaning_services,
      },
      {
        'name': 'Listrik',
        'description': 'Layanan instalasi dan perbaikan sistem listrik.',
        'icon': Icons.electric_bolt,
      },
      {
        'name': 'Layanan AC',
        'description': 'Layanan perbaikan dan perawatan AC.',
        'icon': Icons.ac_unit,
      },
    ];
  }

  @override
  void showServiceDetail(Map<String, dynamic> item) {
    // Implementasi untuk kategori utama
    switch (item['name']) {
      case 'Elektronik':
        Navigator.pushNamed(context, '/elektronik');
        break;
      case 'Bangunan':
        Navigator.pushNamed(context, '/bangunan');
        break;
      case 'Mobil':
        Navigator.pushNamed(context, '/mobil');
        break;
      case 'Cleaning Service':
        Navigator.pushNamed(context, '/cleaning-service');
        break;
      case 'Listrik':
        Navigator.pushNamed(context, '/listrik');
        break;
      case 'Layanan AC':
        Navigator.pushNamed(context, '/layanan-ac');
        break;
      default:
        _showComingSoonDialog(context, item['name']);
    }
  }

  @override
  void onItemPressed(BuildContext context, Map<String, dynamic> item) {
    // Sama dengan showServiceDetail untuk kategori utama
    showServiceDetail(item);
  }

  void _showComingSoonDialog(BuildContext context, String serviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fitur Segera Hadir'),
          content: Text('Layanan $serviceName akan segera tersedia.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
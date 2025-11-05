import 'package:flutter/material.dart';

class TukangScreen extends StatelessWidget {
  const TukangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tukang Home'),
        backgroundColor: const Color(0xFFF3B950),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.build, size: 64, color: Color(0xFFF3B950)),
            SizedBox(height: 16),
            Text(
              'Tukang Screen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

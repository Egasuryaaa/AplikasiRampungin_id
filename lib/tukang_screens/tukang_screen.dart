import 'package:flutter/material.dart';
import 'Widgets/bottom.dart';
import 'content_bottom/home.dart';
import 'content_bottom/withdrawal_screen.dart';

class TukangScreen extends StatefulWidget {
  const TukangScreen({super.key});

  @override
  State<TukangScreen> createState() => _TukangScreenState();
}

class _TukangScreenState extends State<TukangScreen> {
  int _currentIndex = 0; // Default to home

  final List<Widget> _screens = [
    const Home(), // Index 0
    const WithdrawalScreen(), // Index 1
  ];

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Bottom(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }
}

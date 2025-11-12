// File: lib/screens/main_container.dart
import 'package:flutter/material.dart';
import 'Widgets/bottom.dart';
import 'content_bottom/home.dart';
import 'content_bottom/payment.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0; // Default to home

  final List<Widget> _screens = [
    const Home(),    // Index 0
    const Payment(), // Index 1
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
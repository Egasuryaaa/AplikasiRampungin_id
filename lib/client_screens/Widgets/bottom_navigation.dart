// File: lib/screens/Widgets/bottom_navigation.dart
import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  final Function(int)? onTap;
  final int currentIndex;

  const BottomNavigation({super.key, this.onTap, this.currentIndex = 0});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/HomeScreen');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/PaymentScreen');
        break;
    }

    if (widget.onTap != null) {
      widget.onTap!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6B366), Color(0xFFF3B950)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.15),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              0,
              Icons.home_outlined,
              Icons.home,
              'Home',
              isCenter: true,
            ),
            _buildNavItem(
              1,
              Icons.account_balance_wallet_outlined,
              Icons.account_balance_wallet,
              'Payment',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    bool isCenter = false,
  }) {
    bool isSelected = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(index),
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration:
              isCenter && isSelected
                  ? BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  )
                  : isSelected && !isCenter
                  ? BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  )
                  : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: isCenter ? 28 : 24,
                color:
                    isCenter && isSelected
                        ? const Color(0xFFF3B950)
                        : isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isCenter && isSelected
                          ? const Color(0xFFF3B950)
                          : isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

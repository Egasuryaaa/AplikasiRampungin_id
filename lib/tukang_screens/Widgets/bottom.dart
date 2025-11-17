// File: lib/tukang_screens/Widgets/bottom.dart
import 'package:flutter/material.dart';

class Bottom extends StatefulWidget {
  final Function(int)? onTap;
  final int currentIndex;

  const Bottom({super.key, this.onTap, this.currentIndex = 0});

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  void _handleNavigation(int index) {
    // Call callback if provided (for screen switching)
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
            ),
            _buildNavItem(
              1,
              Icons.bar_chart_outlined,
              Icons.bar_chart,
              'Statistik',
            ),
            _buildNavItem(
              2,
              Icons.account_balance_wallet_outlined,
              Icons.account_balance_wallet,
              'Penarikan',
            ),
            _buildNavItem(
              3,
              Icons.person_outline,
              Icons.person,
              'Profil',
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
    String label,
  ) {
    bool isSelected = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: isSelected
              ? BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  size: isSelected ? 26 : 22,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 10 : 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
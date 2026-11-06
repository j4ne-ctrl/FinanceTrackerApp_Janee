import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const AddTransactionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GradientBg(
            child: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _index,
                children: [
                  HomeScreen(onSeeAll: () => setState(() => _index = 1)),
                  const HistoryScreen(),
                  const StatsScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 14),
              child: _NavBar(
                index: _index,
                onTap: (i) => setState(() => _index = i),
                onAdd: _openAdd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;
  const _NavBar(
      {required this.index, required this.onTap, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.glossColors,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.2),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _item(0, Icons.home_rounded, 'Beranda'),
          _item(1, Icons.receipt_long_rounded, 'Riwayat'),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.brandColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.75),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
          _item(2, Icons.bar_chart_rounded, 'Statistik'),
          _item(3, Icons.person_rounded, 'Profil'),
        ],
      ),
    );
  }

  Widget _item(int i, IconData icon, String label) {
    final selected = index == i;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: selected ? 14 : 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 22,
                  color: selected ? AppColors.primaryDark : AppColors.ink.withValues(alpha: 0.55)),
              if (selected) ...[
                const SizedBox(width: 6),
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

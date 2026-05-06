import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../data/bet_provider.dart';
import 'home_screen.dart';
import 'live_screen.dart';
import 'bet_slip_screen.dart';
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LiveScreen(),
    _BetSlipTab(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Consumer<BetProvider>(
        builder: (context, provider, _) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Нүүр',
                      isActive: _currentIndex == 0,
                      onTap: () => setState(() => _currentIndex = 0),
                    ),
                    _NavItem(
                      icon: Icons.sports_outlined,
                      activeIcon: Icons.sports,
                      label: 'Live',
                      isActive: _currentIndex == 1,
                      onTap: () => setState(() => _currentIndex = 1),
                      badge: provider.betSlip
                          .where((b) => true)
                          .length
                          .toString(),
                      showLiveDot: true,
                    ),
                    _NavItem(
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long,
                      label: 'Bet Slip',
                      isActive: _currentIndex == 2,
                      onTap: () => setState(() => _currentIndex = 2),
                      count: provider.betCount,
                    ),
                    _NavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Профайл',
                      isActive: _currentIndex == 3,
                      onTap: () => setState(() => _currentIndex = 3),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BetSlipTab extends StatelessWidget {
  const _BetSlipTab();

  @override
  Widget build(BuildContext context) {
    return const BetSlipScreen();
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int? count;
  final String? badge;
  final bool showLiveDot;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.count,
    this.badge,
    this.showLiveDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.orange : AppColors.textSecondary,
                  size: 24,
                ),
                if (count != null && count! > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (showLiveDot)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.liveRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.orange : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:city_market/views/home_screen.dart';
import 'package:city_market/views/map_view_screen.dart';
import 'package:city_market/views/my_listings_screen.dart';
import 'package:city_market/views/settings_screen.dart';
import 'package:city_market/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final screens = const [
      HomeScreen(),
      MyListingsScreen(),
      MapViewScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryNavy,
                    AppTheme.primaryNavy.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    ref.read(navigationIndexProvider.notifier).state = index;
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: Colors.white.withOpacity(0.2),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined, color: Colors.white.withOpacity(0.6)),
                      selectedIcon: const Icon(Icons.home_rounded, color: Colors.white),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.inventory_2_outlined, color: Colors.white.withOpacity(0.6)),
                      selectedIcon: const Icon(Icons.inventory_2_rounded, color: Colors.white),
                      label: 'Listings',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.map_outlined, color: Colors.white.withOpacity(0.6)),
                      selectedIcon: const Icon(Icons.map_rounded, color: Colors.white),
                      label: 'Map',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined, color: Colors.white.withOpacity(0.6)),
                      selectedIcon: const Icon(Icons.settings_rounded, color: Colors.white),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

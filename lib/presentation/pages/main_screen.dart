import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import 'test_page.dart';
import 'dashboard_page.dart';
import 'deneme_page.dart';
import 'explore_page.dart';
import 'profile_page.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 2; // Default to 'Anasayfa' (index 2)

  final List<Widget> _pages = [
    const TestPage(), // Test
    const DenemePage(), // Deneme
    const DashboardPage(), // Anasayfa
    const ExplorePage(), // Keşfet
    const ProfilePage(), // Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.surface.withValues(alpha: 0.9), // Glass effect
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: theme.divider.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  CupertinoIcons.doc_text,
                  CupertinoIcons.doc_text_fill,
                  'Test',
                  theme,
                ),
                _buildNavItem(
                  1,
                  CupertinoIcons.play_rectangle,
                  CupertinoIcons.play_rectangle_fill,
                  'Deneme',
                  theme,
                ),
                _buildNavItem(
                  2,
                  CupertinoIcons.house,
                  CupertinoIcons.house_fill,
                  'Anasayfa',
                  theme,
                ),
                _buildNavItem(
                  3,
                  CupertinoIcons.chart_pie,
                  CupertinoIcons.chart_pie_fill,
                  'Keşfet',
                  theme,
                ),
                _buildNavItem(
                  4,
                  CupertinoIcons.person,
                  CupertinoIcons.person_fill,
                  'Profil',
                  theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData iconOutlined,
    IconData iconFilled,
    String label,
    AppTheme theme,
  ) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.accent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? iconFilled : iconOutlined,
              color: isSelected ? theme.accent : theme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.accent : theme.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

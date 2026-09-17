import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'productivity_screen.dart';
import 'tasks_screen.dart';

/// The root navigation shell that manages switching between the three main destinations:
/// Home, Tasks, and Productivity, featuring smooth animated icon micro-interactions.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TasksScreen(),
    ProductivityScreen(),
  ];

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: _AnimatedNavIcon(
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard_rounded,
              isSelected: _currentIndex == 0,
            ),
            selectedIcon: const _AnimatedNavIcon(
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard_rounded,
              isSelected: true,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: _AnimatedNavIcon(
              icon: Icons.check_box_outlined,
              selectedIcon: Icons.check_box_rounded,
              isSelected: _currentIndex == 1,
            ),
            selectedIcon: const _AnimatedNavIcon(
              icon: Icons.check_box_outlined,
              selectedIcon: Icons.check_box_rounded,
              isSelected: true,
            ),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: _AnimatedNavIcon(
              icon: Icons.insights_outlined,
              selectedIcon: Icons.insights_rounded,
              isSelected: _currentIndex == 2,
            ),
            selectedIcon: const _AnimatedNavIcon(
              icon: Icons.insights_outlined,
              selectedIcon: Icons.insights_rounded,
              isSelected: true,
            ),
            label: 'Productivity',
          ),
        ],
      ),
    );
  }
}

/// A micro-animated navigation icon that bounces and scales smoothly when tapped/selected.
class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;

  const _AnimatedNavIcon({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<bool>(isSelected),
      tween: Tween<double>(begin: isSelected ? 0.7 : 1.15, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Icon(
            isSelected ? selectedIcon : icon,
            size: isSelected ? 26 : 24,
          ),
        );
      },
    );
  }
}

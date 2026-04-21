import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'home_tab.dart';
import 'explore_screen.dart';
import 'activity_tab.dart';
import 'profile_tab.dart';
import 'ai_diagnostic_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // lib/features/home/presentation/screens/home_screen.dart

  @override
  Widget build(BuildContext context) {
    // We removed the BlocProvider from here because it's now in main.dart
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            onExploreTap: () => setState(() => _currentIndex = 1),
            onAiTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiDiagnosticScreen()),
            ),
          ),
          const ExploreScreen(),
          const ActivityTab(),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

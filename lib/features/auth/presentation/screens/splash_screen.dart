import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'language_selection_screen.dart'; // We will create this next

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds then go to Language Selection
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Replace this Icon with an Image.asset later when you have the logo
                Icon(Icons.location_on, size: 100, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'RoadHero',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v1.0.0',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
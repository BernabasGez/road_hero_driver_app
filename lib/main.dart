import 'package:flutter/material.dart';
import 'package:road_hero/core/di/injection_container.dart' as di;
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Call the initialization function from the DI file
  await di.init();

  runApp(const RoadHeroApp());
}

class RoadHeroApp extends StatelessWidget {
  const RoadHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoadHero',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

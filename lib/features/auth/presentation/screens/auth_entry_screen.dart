import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The top half uses the primary blue from your Figma design
      backgroundColor: AppColors.primaryBlue,
      body: Column(
        children: [
          // This Expanded space creates the top blue area with the logo
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 80, color: Colors.white),
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
          ),

          // This is the White Card at the bottom (Figma 2.0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Roadside Assistance,\nReimagined.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 40),

                // CREATE ACCOUNT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // LOG IN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'By continuing, you agree to our Terms & Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

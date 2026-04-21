import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'onboarding_screen.dart'; // Import the onboarding screen we just made

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // Default selected language is English
  String selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Figma 1.1 Header
              const Text(
                'Welcome /',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 40),

              // Language Option: English
              _buildLanguageOption(title: 'English', flag: '🇬🇧', value: 'en'),

              const SizedBox(height: 16),

              // Language Option: Amharic
              _buildLanguageOption(
                title: 'አማርኛ (Amharic)',
                flag: '🇪🇹',
                value: 'am',
              ),

              const Spacer(),

              // CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardingScreen(
                          onComplete: () {
                            // Tell the app to go to the entry screen when onboarding is done
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
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
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // This is a helper function to create the English/Amharic boxes
  Widget _buildLanguageOption({
    required String title,
    required String flag,
    required String value,
  }) {
    bool isSelected = selectedLanguage == value;

    return GestureDetector(
      onTap: () => setState(() => selectedLanguage = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Changed .withOpacity to .withValues
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.05)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }
}

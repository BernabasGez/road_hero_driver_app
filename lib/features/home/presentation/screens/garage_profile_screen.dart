import 'package:flutter/material.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/home/data/models/provider_model.dart';

class GarageProfileScreen extends StatelessWidget {
  final ProviderModel provider;
  const GarageProfileScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.businessName),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.store, size: 100, color: AppColors.primaryBlue),
            const SizedBox(height: 20),
            Text(
              provider.businessName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionOrange,
                ),
                child: const Text(
                  "Request Service",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

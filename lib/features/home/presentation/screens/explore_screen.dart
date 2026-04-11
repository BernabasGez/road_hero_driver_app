import 'package:flutter/material.dart';
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/home/data/models/provider_model.dart';
import 'package:road_hero/features/home/data/repositories/home_remote_source.dart';
import 'package:road_hero/features/home/presentation/screens/garage_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<ProviderModel> providers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGarages();
  }

  Future<void> _fetchGarages() async {
    setState(() => isLoading = true);
    try {
      final list = await sl<HomeRemoteSource>().getNearbyProviders();
      if (mounted)
        setState(() {
          providers = list;
          isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Garages Near You",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : providers.isEmpty
          ? const Center(child: Text("No garages found in this area."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: providers.length,
              itemBuilder: (context, index) =>
                  _buildGarageCard(providers[index]),
            ),
    );
  }

  Widget _buildGarageCard(ProviderModel garage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: const Icon(Icons.build, color: AppColors.primaryBlue),
        ),
        title: Text(
          garage.businessName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${garage.rating} ⭐ • ${garage.distanceKm} km away"),
            const SizedBox(height: 4),
            Text(
              garage.services.join(" • "),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GarageProfileScreen(provider: garage),
          ),
        ),
      ),
    );
  }
}

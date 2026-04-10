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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGarages();
  }

  Future<void> _fetchGarages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final list = await sl<HomeRemoteSource>().getNearbyProviders();
      if (mounted) {
        setState(() {
          providers = list;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString().replaceAll("Exception: ", "");
          isLoading = false;
        });
      }
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              TextButton(onPressed: _fetchGarages, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No garages found in this area.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "Try increasing your search radius.",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(onPressed: _fetchGarages, child: const Text("Refresh")),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: providers.length,
      itemBuilder: (context, index) => _buildGarageCard(providers[index]),
    );
  }

  Widget _buildGarageCard(ProviderModel garage) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.build, color: Colors.white),
        ),
        title: Text(
          garage.businessName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${garage.rating} ⭐ • ${garage.distanceKm} km away"),
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

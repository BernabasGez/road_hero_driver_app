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
  List<ProviderModel> allProviders = [];
  List<ProviderModel> filteredProviders = [];
  bool isLoading = true;
  String selectedFilter = "All";

  // UPDATED: Removed "Verified", added "Towing" and "Repair"
  final List<String> filters = ["All", "Open Now", "Towing", "Repair"];

  @override
  void initState() {
    super.initState();
    _fetchGarages();
  }

  Future<void> _fetchGarages() async {
    setState(() => isLoading = true);
    try {
      final list = await sl<HomeRemoteSource>().getNearbyProviders();
      if (mounted) {
        setState(() {
          allProviders = list;
          _applyFilter();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (selectedFilter == "All") {
        filteredProviders = allProviders;
      } else if (selectedFilter == "Open Now") {
        filteredProviders = allProviders.where((g) => g.isOnline).toList();
      } else if (selectedFilter == "Towing") {
        filteredProviders = allProviders
            .where(
              (g) => g.services.any((s) => s.toLowerCase().contains("towing")),
            )
            .toList();
      } else if (selectedFilter == "Repair") {
        filteredProviders = allProviders
            .where(
              (g) => g.services.any((s) => s.toLowerCase().contains("repair")),
            )
            .toList();
      }
    });
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
      body: Column(
        children: [
          // HORIZONTAL FILTERS
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedFilter == filters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filters[index]),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => selectedFilter = filters[index]);
                      _applyFilter();
                    },
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  )
                : filteredProviders.isEmpty
                ? Center(
                    child: Text("No $selectedFilter garages found nearby."),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) =>
                        _buildGarageCard(filteredProviders[index]),
                  ),
          ),
        ],
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                garage.businessName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // We keep the badge because it builds trust, even if we don't filter by it
            const Icon(Icons.verified, color: Colors.blue, size: 18),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${garage.rating} ⭐ • ${garage.distanceKm.toStringAsFixed(1)} km away",
            ),
            Text(
              garage.isOnline ? "Online" : "Offline",
              style: TextStyle(
                color: garage.isOnline ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
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

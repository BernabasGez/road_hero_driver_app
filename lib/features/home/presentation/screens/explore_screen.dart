import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  // FILTERS STATE
  bool onlyOnline = false;
  int? selectedServiceId; // null = All
  double selectedRadius = 500.0; // 500.0 = "All"

  final List<Map<String, dynamic>> services = [
    {"name": "All", "id": null},
    {"name": "Towing", "id": 1},
    {"name": "Repair", "id": 2},
    {"name": "Tire", "id": 3},
    {"name": "Fuel", "id": 4},
  ];

  @override
  void initState() {
    super.initState();
    _fetchGarages();
  }

  Future<void> _fetchGarages() async {
    setState(() => isLoading = true);
    try {
      Position pos = await Geolocator.getCurrentPosition();
      final list = await sl<HomeRemoteSource>().getNearbyProviders(
        lat: pos.latitude,
        lng: pos.longitude,
        radius: selectedRadius,
        isOnline: onlyOnline ? true : null,
        serviceTypeId: selectedServiceId,
      );
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
          "Explore Garages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // FILTER HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade50),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ONLINE TOGGLE
                    _buildOnlineToggle(),
                    // RADIUS DROPDOWN
                    _buildRadiusDropdown(),
                  ],
                ),
                const SizedBox(height: 12),
                // SERVICE TYPE CHIPS
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length,
                    itemBuilder: (context, index) =>
                        _serviceChip(services[index]),
                  ),
                ),
              ],
            ),
          ),

          // RESULTS LIST
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  )
                : providers.isEmpty
                ? const Center(
                    child: Text("No garages found with these filters."),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: providers.length,
                    itemBuilder: (context, index) =>
                        _buildGarageCard(providers[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineToggle() {
    return Row(
      children: [
        const Text(
          "Online Only",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Switch.adaptive(
          value: onlyOnline,
          activeColor: Colors.green,
          onChanged: (val) {
            setState(() => onlyOnline = val);
            _fetchGarages();
          },
        ),
      ],
    );
  }

  Widget _buildRadiusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: selectedRadius,
          items: const [
            DropdownMenuItem(value: 10.0, child: Text("10 km")),
            DropdownMenuItem(value: 15.0, child: Text("15 km")),
            DropdownMenuItem(value: 20.0, child: Text("20 km")),
            DropdownMenuItem(value: 500.0, child: Text("All Radius")),
          ],
          onChanged: (val) {
            setState(() => selectedRadius = val!);
            _fetchGarages();
          },
        ),
      ),
    );
  }

  Widget _serviceChip(Map<String, dynamic> service) {
    bool isSelected = selectedServiceId == service['id'];
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(service['name']),
        selected: isSelected,
        onSelected: (val) {
          setState(() => selectedServiceId = service['id']);
          _fetchGarages();
        },
        selectedColor: AppColors.primaryBlue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
        ),
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
          backgroundColor: AppColors.primaryBlue.withAlpha(20),
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
            if (garage.isVerified)
              const Icon(Icons.verified, color: Colors.blue, size: 18),
          ],
        ),
        subtitle: Text(
          "${garage.rating} ⭐ • ${garage.distanceKm.toStringAsFixed(1)} km\nStatus: ${garage.isOnline ? 'Online' : 'Offline'}",
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

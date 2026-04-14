import 'package:flutter/material.dart';
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/home/data/repositories/home_remote_source.dart';

class RequestHistoryDetailScreen extends StatelessWidget {
  final int requestId;
  const RequestHistoryDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Summary #$requestId"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: sl<HomeRemoteSource>().getRequestDetail(requestId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text("Unable to load details. Try again."),
            );
          }

          final data = snapshot.data!;
          final garage =
              data['provider']?['business_name'] ??
              data['provider']?['name'] ??
              "Garage";
          final vehicle = data['vehicle'];
          final address = data['incident_address'] ?? "Addis Ababa, Ethiopia";
          final issue = data['description'] ?? "No details provided.";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailTile("Assigned Garage", garage, Icons.store),
                _detailTile(
                  "Status",
                  data['status'] ?? "PENDING",
                  Icons.info_outline,
                ),
                const Divider(height: 40),
                _detailTile("Location", address, Icons.location_on),
                if (vehicle != null)
                  _detailTile(
                    "Vehicle",
                    "${vehicle['make']?['name'] ?? ''} - ${vehicle['plate_number'] ?? ''}",
                    Icons.directions_car,
                  ),
                const Divider(height: 40),
                const Text(
                  "Problem Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Text(issue, style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

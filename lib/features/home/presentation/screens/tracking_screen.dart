import 'dart:async';
import 'package:flutter/material.dart';
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/home/data/repositories/home_remote_source.dart';

class TrackingScreen extends StatefulWidget {
  final int requestId;
  final String garageName;

  const TrackingScreen({
    super.key,
    required this.requestId,
    required this.garageName,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Timer? _timer;
  Map<String, dynamic>? trackingData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Requirements check: Refresh status every 10 seconds
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) => _fetchStatus(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final data = await sl<HomeRemoteSource>().getLiveTracking(
        widget.requestId,
      );
      if (mounted) {
        setState(() {
          trackingData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Tracking update failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = trackingData?['status'] ?? "PENDING";
    int eta = trackingData?['eta_minutes'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.garageName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: status == "EN_ROUTE"
                ? Colors.green.shade50
                : Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.stars,
                  color: status == "EN_ROUTE"
                      ? Colors.green
                      : AppColors.primaryBlue,
                ),
                const SizedBox(width: 12),
                Text(
                  status == "EN_ROUTE"
                      ? "Mechanic on the way"
                      : "Request Received",
                  style: TextStyle(
                    color: status == "EN_ROUTE"
                        ? Colors.green
                        : AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (eta > 0)
                  Text(
                    "$eta mins",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: Icon(Icons.map, size: 80, color: Colors.grey),
              ),
            ),
          ),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(radius: 25, child: Icon(Icons.person)),
            title: Text(
              trackingData?['technician_name'] ?? "Assigning...",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: const Text("Verified Technician"),
            trailing: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: const Icon(
                Icons.phone,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Cancel Request",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

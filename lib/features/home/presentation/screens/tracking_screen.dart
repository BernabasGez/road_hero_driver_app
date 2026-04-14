import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
      debugPrint("Tracking failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = trackingData?['status'] ?? "PENDING";
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.garageName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: status == "EN_ROUTE"
                      ? Colors.green.shade50
                      : Colors.blue.shade50,
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: status == "EN_ROUTE"
                            ? Colors.green
                            : AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        status == "EN_ROUTE"
                            ? "Mechanic on the way"
                            : "Waiting for Mechanic",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(9.02497, 38.74689),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.bernabas.roadhero',
                      ),
                    ],
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(trackingData?['technician_name'] ?? "Assigning soon..."),
        subtitle: const Text("Verified Professional"),
        trailing: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(
            Icons.phone,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/home/data/repositories/home_remote_source.dart';
import 'package:road_hero/features/home/presentation/screens/tracking_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<dynamic> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final data = await sl<HomeRemoteSource>().getMyRequests();
    if (mounted) {
      setState(() {
        requests = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Activity",
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
          : requests.isEmpty
          ? const Center(child: Text("No requests found."))
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) =>
                    _buildRequestCard(requests[index]),
              ),
            ),
    );
  }

  Widget _buildRequestCard(dynamic req) {
    final String status = req['status'] ?? "PENDING";
    final String garageName = req['provider']?['business_name'] ?? "Garage";
    final int requestId = req['id'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              garageName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            _statusBadge(status),
          ],
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text("Service: General Repair"),
        ),
        onTap: () {
          // FIXED: Passing the required 'garageName' parameter
          if (status == "PENDING" ||
              status == "EN_ROUTE" ||
              status == "ACCEPTED") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrackingScreen(
                  requestId: requestId,
                  garageName: garageName,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // FIXED: Using color.withAlpha instead of withOpacity to avoid deprecation
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/home/data/models/provider_model.dart';
import 'package:road_hero/features/home/data/models/vehicle_model.dart';
import 'package:road_hero/features/home/data/repositories/profile_remote_source.dart';
import 'package:road_hero/features/home/presentation/screens/confirm_location_screen.dart';

class RequestDetailsScreen extends StatefulWidget {
  final ProviderModel provider;
  const RequestDetailsScreen({super.key, required this.provider});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final TextEditingController _issueController = TextEditingController();
  List<VehicleModel> vehicles = [];
  int? selectedVehicleId;
  bool isLoadingVehicles = true;

  @override
  void initState() {
    super.initState();
    _fetchMyVehicles();
  }

  Future<void> _fetchMyVehicles() async {
    final list = await sl<ProfileRemoteSource>().getVehicles();
    setState(() {
      vehicles = list;
      if (list.isNotEmpty) selectedVehicleId = list[0].id;
      isLoadingVehicles = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Request Details"),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoadingVehicles
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Which vehicle needs help?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedVehicleId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: vehicles
                        .map(
                          (v) => DropdownMenuItem<int>(
                            value: v.id,
                            child: Text("${v.make} (${v.plateNumber})"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedVehicleId = val),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Describe the problem",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _issueController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "e.g. Engine making loud noise",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedVehicleId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please add a vehicle first in Profile",
                              ),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmLocationScreen(
                              provider: widget.provider,
                              description: _issueController.text,
                              vehicleId: selectedVehicleId!, // PASSING REAL ID
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionOrange,
                      ),
                      child: const Text(
                        "Next: Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

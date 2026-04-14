import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/core/di/injection_container.dart';
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
  File? _selectedImage;
  bool isLoading = true;

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
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Vehicle",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedVehicleId,
                    items: vehicles
                        .map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text("${v.make} (${v.plateNumber})"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedVehicleId = val),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Describe Problem",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _issueController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "What is wrong?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // PHOTO SELECTOR (Figma 7.1)
                  const Text(
                    "Add Photo (Optional)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _selectedImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Colors.grey,
                                ),
                                Text(
                                  "Tap to add photo",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_issueController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please describe the problem"),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConfirmLocationScreen(
                              provider: widget.provider,
                              description: _issueController.text,
                              vehicleId: selectedVehicleId!,
                              imageFile: _selectedImage, // Pass the file
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

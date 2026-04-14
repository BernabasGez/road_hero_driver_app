import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/features/home/data/models/provider_model.dart';
import 'package:road_hero/features/home/data/repositories/home_remote_source.dart';
import 'package:road_hero/features/home/presentation/screens/tracking_screen.dart';

class ConfirmLocationScreen extends StatefulWidget {
  final ProviderModel provider;
  final String description;
  final int vehicleId;
  final File? imageFile;

  const ConfirmLocationScreen({
    super.key,
    required this.provider,
    required this.description,
    required this.vehicleId,
    this.imageFile,
  });

  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
  bool isSubmitting = false;
  LatLng _pickupPosition = const LatLng(9.02497, 38.74689);

  Future<void> _submitRequest() async {
    setState(() => isSubmitting = true);
    String? finalImageUrl;

    try {
      // 1. Upload photo if it exists
      if (widget.imageFile != null) {
        final uploadData = await sl<HomeRemoteSource>().getUploadUrl(
          "emergency_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );
        await Dio().put(
          uploadData['upload_url'],
          data: widget.imageFile!.openRead(),
          options: Options(
            headers: {
              "Content-Type": "image/jpeg",
              "Content-Length": widget.imageFile!.lengthSync(),
            },
          ),
        );
        finalImageUrl = uploadData['file_url'];
      }

      // 2. Submit Emergency Request
      final requestId = await sl<HomeRemoteSource>().createRequest(
        providerId: widget.provider.id,
        vehicleId: widget.vehicleId,
        issueDescription: widget.description,
        imageUrl: finalImageUrl,
        lat: _pickupPosition.latitude,
        lng: _pickupPosition.longitude,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            content: const Text("Emergency request sent! Stay safe."),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackingScreen(
                          requestId: requestId,
                          garageName: widget.provider.businessName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: const Text(
                    "Track Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.toString().replaceAll("Exception: ", "")}",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _pickupPosition,
              initialZoom: 16,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture && pos.center != null)
                  _pickupPosition = pos.center!;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'org.roadhero.driver',
              ),
            ],
          ),
          const Center(
            child: Icon(
              Icons.location_on,
              size: 50,
              color: AppColors.primaryBlue,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Confirm Emergency Pickup",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionOrange,
                      ),
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Request Assistance Now",
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
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/features/home/data/models/provider_model.dart';
import 'package:road_hero/features/home/data/repositories/home_remote_source.dart';

class ConfirmLocationScreen extends StatefulWidget {
  final ProviderModel provider;
  final String description;
  final int vehicleId; // New parameter

  const ConfirmLocationScreen({
    super.key,
    required this.provider,
    required this.description,
    required this.vehicleId,
  });

  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
  bool isSubmitting = false;

  Future<void> _submitRequest() async {
    setState(() => isSubmitting = true);
    try {
      final requestId = await sl<HomeRemoteSource>().createRequest(
        providerId: widget.provider.id,
        vehicleId: widget.vehicleId, // SENDING REAL ID
        issueDescription: widget.description,
        lat: 9.0192,
        lng: 38.7525,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Request Successful!"),
            content: Text(
              "Your request #$requestId has been sent. Check the Activity tab for updates.",
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("Done"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(
                Icons.location_on,
                size: 80,
                color: AppColors.primaryBlue,
              ),
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
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Pickup Point",
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
                              "Confirm & Request",
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

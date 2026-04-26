import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/datasources/home_remote_source.dart';
import '../../data/models/provider_model.dart';
import '../../data/models/cart_item_model.dart';
import '../bloc/cart_cubit.dart';
import 'tracking_screen.dart';

class ConfirmRequestScreen extends StatefulWidget {
  final ProviderModel provider;
  final String description;
  final int vehicleId;
  final int serviceTypeId;
  final File? imageFile;
  final LatLng location;
  final List<CartItemModel> cartItems;

  const ConfirmRequestScreen({
    super.key,
    required this.provider,
    required this.description,
    required this.vehicleId,
    required this.serviceTypeId,
    this.imageFile,
    required this.location,
    required this.cartItems,
  });

  @override
  State<ConfirmRequestScreen> createState() => _ConfirmRequestScreenState();
}

class _ConfirmRequestScreenState extends State<ConfirmRequestScreen> {
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final result = await sl<HomeRemoteSource>().createRequest(
        providerId: widget.provider.id,
        serviceTypeId: widget.serviceTypeId,
        vehicleId: widget.vehicleId,
        description: widget.description,
        lat: widget.location.latitude,
        lng: widget.location.longitude,
        photo: widget.imageFile,
        spareParts: widget.cartItems.map((e) => e.toJson()).toList(),
      );

      if (mounted) {
        context.read<CartCubit>().clearCart();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => TrackingScreen(
              requestId: result.id,
              garageName: widget.provider.businessName,
            ),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request Failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double partsTotal = widget.cartItems.fold(
      0,
      (sum, item) => sum + item.total,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Final Review"),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Review your request details before sending them to the garage.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 32),

              // Summary Details
              _detailItem(
                "Garage",
                widget.provider.businessName,
                Icons.storefront,
              ),
              _detailItem(
                "Issue",
                widget.description,
                Icons.report_problem_outlined,
              ),
              if (widget.cartItems.isNotEmpty)
                _detailItem(
                  "Requested Parts",
                  "${widget.cartItems.length} items (${partsTotal.toStringAsFixed(0)} ETB)",
                  Icons.shopping_bag_outlined,
                ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Location Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Your exact GPS location is being shared with the mechanic.",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              if (widget.imageFile != null)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "📎 Photo Attachment Included",
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              AppButton(
                label: "Confirm & Request Assistance",
                isLoading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

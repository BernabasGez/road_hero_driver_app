import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/datasources/home_remote_source.dart';
import '../../data/models/provider_model.dart';
import 'tracking_screen.dart';

class ConfirmLocationScreen extends StatefulWidget {
  final ProviderModel provider;
  final String description;
  final int vehicleId;
  final int serviceTypeId;
  final File? imageFile;

  const ConfirmLocationScreen({
    super.key,
    required this.provider,
    required this.description,
    required this.vehicleId,
    required this.serviceTypeId,
    this.imageFile,
  });

  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
  bool _submitting = false;
  LatLng _position = const LatLng(AppConfig.defaultLat, AppConfig.defaultLng);

  @override
  void initState() {
    super.initState();
    _setLocation();
  }

  Future<void> _setLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _position = LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final result = await sl<HomeRemoteSource>().createRequest(
        providerId: widget.provider.id,
        serviceTypeId: widget.serviceTypeId,
        vehicleId: widget.vehicleId,
        description: widget.description,
        lat: _position.latitude,
        lng: _position.longitude,
        photo: widget.imageFile,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 56),
            content: const Text(
              'Your request has been sent!\nThe garage will respond shortly.',
              textAlign: TextAlign.center,
            ),
            actions: [
              AppButton(
                label: 'Track Request',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackingScreen(
                        requestId: result.id,
                        garageName: widget.provider.businessName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            options: MapOptions(
              initialCenter: _position,
              initialZoom: 16,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  _position = pos.center;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: AppConfig.mapTileUrl,
                userAgentPackageName: AppConfig.mapUserAgent,
              ),
            ],
          ),
          // Center pin
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 28),
                  ),
                  Container(width: 3, height: 16, color: AppColors.primary),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          // Bottom sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 16)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    'Drag map to set breakdown location',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  AppButton(
                    label: 'Confirm & Send Request',
                    isLoading: _submitting,
                    onPressed: _submit,
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/provider_model.dart';
import '../bloc/home_cubit.dart';
import 'confirm_location_screen.dart';

class RequestDetailsScreen extends StatefulWidget {
  final ProviderModel provider;
  final int? preSelectedServiceType;
  const RequestDetailsScreen({super.key, required this.provider, this.preSelectedServiceType});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final _descCtrl = TextEditingController();
  File? _image;
  int? _selectedVehicleId;
  int? _selectedServiceTypeId;
  final bool _isScheduled = false;

  @override
  void initState() {
    super.initState();
    _selectedServiceTypeId = widget.preSelectedServiceType;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Request Details')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          final vehicles = homeState.vehicles;
          final serviceTypes = homeState.serviceTypes;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider info
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.store_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.provider.businessName,
                                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                            if (widget.provider.distanceKm != null)
                              Text('${widget.provider.distanceKm!.toStringAsFixed(1)} km away',
                                  style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // Vehicle selection
                const Text('Select Vehicle', style: AppTextStyles.label),
                const SizedBox(height: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedVehicleId,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Choose vehicle', style: AppTextStyles.inputHint),
                    items: vehicles.map((v) {
                      return DropdownMenuItem(value: v.id, child: Text('${v.displayName} (${v.plateNumber})'));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedVehicleId = v),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // Service type
                const Text('Service Type', style: AppTextStyles.label),
                const SizedBox(height: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedServiceTypeId,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Choose service', style: AppTextStyles.inputHint),
                    items: serviceTypes.map((st) {
                      return DropdownMenuItem(value: st['id'] as int, child: Text(st['name'] ?? ''));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedServiceTypeId = v),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // Description
                AppTextField(
                  controller: _descCtrl,
                  label: 'Describe the issue',
                  hint: 'e.g. Flat tire on Bole Road',
                  maxLines: 4,
                ),
                const SizedBox(height: AppDimensions.md),

                // Image
                const Text('Photo (optional)', style: AppTextStyles.label),
                const SizedBox(height: AppDimensions.sm),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: AppColors.textHint, size: 32),
                              SizedBox(height: 8),
                              Text('Tap to add photo', style: AppTextStyles.caption),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // CTA
                AppButton(
                  label: 'Confirm Location',
                  icon: Icons.location_on_outlined,
                  onPressed: () {
                    if (_selectedVehicleId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a vehicle')),
                      );
                      return;
                    }
                    if (_selectedServiceTypeId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a service type')),
                      );
                      return;
                    }
                    if (_descCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please describe the issue')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConfirmLocationScreen(
                          provider: widget.provider,
                          description: _descCtrl.text.trim(),
                          vehicleId: _selectedVehicleId!,
                          serviceTypeId: _selectedServiceTypeId!,
                          imageFile: _image,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

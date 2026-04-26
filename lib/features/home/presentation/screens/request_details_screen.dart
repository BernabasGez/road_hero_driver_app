import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:road_hero/features/home/presentation/bloc/cart_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/provider_model.dart';
import '../bloc/home_cubit.dart';
import 'confirm_request_screen.dart'; // Renamed from ConfirmLocation

class RequestDetailsScreen extends StatefulWidget {
  final ProviderModel provider;
  final int? preSelectedServiceType;
  const RequestDetailsScreen({
    super.key,
    required this.provider,
    this.preSelectedServiceType,
  });

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final _descCtrl = TextEditingController();
  File? _image;
  int? _selectedVehicleId;
  int? _selectedServiceTypeId;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedServiceTypeId = widget.preSelectedServiceType;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _proceed() async {
    if (_selectedVehicleId == null ||
        _selectedServiceTypeId == null ||
        _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isGettingLocation = true);

    try {
      // Automatically get location without showing a map
      Position pos = await Geolocator.getCurrentPosition();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmRequestScreen(
              provider: widget.provider,
              description: _descCtrl.text,
              vehicleId: _selectedVehicleId!,
              serviceTypeId: _selectedServiceTypeId!,
              imageFile: _image,
              location: LatLng(pos.latitude, pos.longitude),
              cartItems: context.read<CartCubit>().state.items,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not get GPS location")),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Request Details'), elevation: 0.5),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          final cartItems = context.watch<CartCubit>().state.items;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Garage Header
                _buildSectionHeader(
                  widget.provider.businessName,
                  Icons.store_outlined,
                ),
                const SizedBox(height: 20),

                // Vehicle Selection
                const Text('Select Vehicle', style: AppTextStyles.label),
                _buildDropdown(
                  value: _selectedVehicleId,
                  hint: "Choose your vehicle",
                  items: homeState.vehicles
                      .map(
                        (v) => DropdownMenuItem(
                          value: v.id,
                          child: Text(v.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedVehicleId = v),
                ),
                const SizedBox(height: 20),

                // Service Selection
                const Text('Service Type', style: AppTextStyles.label),
                _buildDropdown(
                  value: _selectedServiceTypeId,
                  hint: "What help do you need?",
                  items: homeState.serviceTypes
                      .map(
                        (st) => DropdownMenuItem(
                          value: st['id'] as int,
                          child: Text(st['name'] ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedServiceTypeId = v),
                ),
                const SizedBox(height: 20),

                // Spare Parts Cart
                if (cartItems.isNotEmpty) ...[
                  const Text(
                    'Spare Parts to Bring',
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(height: 8),
                  _buildCartSummary(cartItems),
                  const SizedBox(height: 20),
                ],

                // Photo Upload (Restored)
                const Text('Photo of the issue', style: AppTextStyles.label),
                const SizedBox(height: 8),
                _buildPhotoPicker(),
                const SizedBox(height: 20),

                // Description
                AppTextField(
                  controller: _descCtrl,
                  label: 'Issue Description',
                  hint: 'Describe the noise or problem...',
                  maxLines: 3,
                ),
                const SizedBox(height: 30),

                AppButton(
                  label: 'Review Request',
                  isLoading: _isGettingLocation,
                  onPressed: _proceed,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildDropdown({
    required int? value,
    required String hint,
    required List<DropdownMenuItem<int>> items,
    required Function(int?) onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        isExpanded: true,
        hint: Text(hint, style: AppTextStyles.bodySmall),
        items: items,
        onChanged: onChanged,
      ),
    ),
  );

  Widget _buildCartSummary(List cartItems) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: cartItems
          .map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${item.quantity}x ${item.name}",
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    "${item.total.toStringAsFixed(0)} ETB",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _buildPhotoPicker() => GestureDetector(
    onTap: _pickImage,
    child: Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_image!, fit: BoxFit.cover),
            )
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, color: Colors.grey),
                Text(
                  "Take a photo",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
    ),
  );
}

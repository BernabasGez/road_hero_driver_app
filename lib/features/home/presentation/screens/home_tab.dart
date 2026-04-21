import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../bloc/home_cubit.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback onExploreTap;
  final VoidCallback onAiTap;
  final void Function(int serviceTypeId)? onServiceTap;

  const HomeTab({
    super.key,
    required this.onExploreTap,
    required this.onAiTap,
    this.onServiceTap,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  LatLng _currentPosition = const LatLng(AppConfig.defaultLat, AppConfig.defaultLng);
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadLocation();
    context.read<HomeCubit>().loadDashboard();
  }

  Future<void> _loadLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            // ─── Header ──────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding,
                  MediaQuery.of(context).padding.top + 16,
                  AppDimensions.screenPadding,
                  AppDimensions.md,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.read<HomeCubit>().greeting,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              state.isLoading
                                  ? const SkeletonLoader(width: 140, height: 20)
                                  : Text(
                                      state.user?.fullName ?? 'Driver',
                                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                                    ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    // Search bar
                    GestureDetector(
                      onTap: widget.onExploreTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Find a garage near you...',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ─── Map Preview ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition,
                        initialZoom: AppConfig.defaultZoom,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: AppConfig.mapTileUrl,
                          userAgentPackageName: AppConfig.mapUserAgent,
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            point: _currentPosition,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.my_location, color: Colors.white, size: 18),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Services ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Services', style: AppTextStyles.sectionHeader),
                    const SizedBox(height: AppDimensions.md),
                    _buildServiceGrid(state),
                  ],
                ),
              ),
            ),

            // ─── AI Banner ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: GestureDetector(
                  onTap: widget.onAiTap,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Virtual Mechanic',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Describe symptoms for instant diagnostics',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildServiceGrid(HomeState state) {
    final defaultServices = [
      {'icon': Icons.build_outlined, 'name': 'Repair', 'color': AppColors.primary},
      {'icon': Icons.local_shipping_outlined, 'name': 'Towing', 'color': AppColors.accent},
      {'icon': Icons.tire_repair_outlined, 'name': 'Tire', 'color': AppColors.success},
      {'icon': Icons.local_gas_station_outlined, 'name': 'Fuel', 'color': AppColors.warning},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: defaultServices.length,
      itemBuilder: (_, i) {
        final s = defaultServices[i];
        return GestureDetector(
          onTap: () {
            if (widget.onServiceTap != null && state.serviceTypes.isNotEmpty) {
              widget.onServiceTap!(state.serviceTypes.length > i
                  ? state.serviceTypes[i]['id'] ?? (i + 1)
                  : i + 1);
            } else {
              widget.onExploreTap();
            }
          },
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (s['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                s['name'] as String,
                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

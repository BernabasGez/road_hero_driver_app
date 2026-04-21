import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/datasources/home_remote_source.dart';
import '../../data/models/provider_model.dart';
import 'garage_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  final int? preFilterServiceTypeId;
  const ExploreScreen({super.key, this.preFilterServiceTypeId});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<ProviderModel> _providers = [];
  bool _loading = true;
  String? _error;

  // Filter States
  bool _onlineOnly = false;
  int? _selectedServiceType;
  String _sortBy = 'distance';

  LatLng _position = const LatLng(AppConfig.defaultLat, AppConfig.defaultLng);
  List<Map<String, dynamic>> _serviceTypes = [];
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _selectedServiceType = widget.preFilterServiceTypeId;
    _init();
  }

  Future<void> _init() async {
    try {
      // 1. Instant check for last location
      Position? lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        _position = LatLng(lastPos.latitude, lastPos.longitude);
      }

      // 2. Refresh location with a strict 4-second timeout to avoid infinite loading
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 4),
      );
      _position = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint("Location fallback used: $e");
    }

    _loadServiceTypes();
    _search();
  }

  Future<void> _loadServiceTypes() async {
    try {
      final types = await sl<HomeRemoteSource>().getServiceTypes();
      if (mounted) setState(() => _serviceTypes = types);
    } catch (_) {}
  }

  Future<void> _search() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final providers = await sl<HomeRemoteSource>()
          .getNearbyProviders(
            lat: _position.latitude,
            lng: _position.longitude,
            radiusKm: 500.0,
            isOnline: _onlineOnly ? true : null,
            serviceTypeId: _selectedServiceType,
            sortBy: _sortBy,
          )
          .timeout(const Duration(seconds: 10)); // Prevent API hang

      if (mounted) {
        setState(() {
          _providers = providers;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Connection timeout. Tap to retry.";
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Garages'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list_outlined : Icons.map_outlined),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _loading
                ? const SkeletonList()
                : _error != null
                ? ErrorView(message: _error!, onRetry: _search)
                : _providers.isEmpty
                ? const EmptyView(
                    title: 'No garages found',
                    subtitle: 'Try changing your filters',
                    icon: Icons.search_off_outlined,
                  )
                : _showMap
                ? _buildMapView()
                : _buildListView(),
          ),
        ],
      ),
    );
  }

  // --- REFINED CLEAN FILTERS ---
  Widget _buildFilters() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // ROW 1: Toggles and Sorting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Online Now'),
                  selected: _onlineOnly,
                  onSelected: (v) {
                    setState(() => _onlineOnly = v);
                    _search();
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _onlineOnly ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                // Custom Sort Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isDense: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'distance',
                        child: Text('Nearest'),
                      ),
                      DropdownMenuItem(
                        value: 'rating',
                        child: Text('Top Rated'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _sortBy = v);
                        _search();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ROW 2: Service Categories (Scrollable)
          if (_serviceTypes.isNotEmpty)
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _serviceTypes.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final isAll = i == 0;
                  final id = isAll ? null : _serviceTypes[i - 1]['id'];
                  final name = isAll
                      ? 'All Services'
                      : _serviceTypes[i - 1]['name'];
                  final isSelected = _selectedServiceType == id;

                  return ChoiceChip(
                    label: Text(name),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedServiceType = id);
                      _search();
                    },
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _search,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _providers.length,
        itemBuilder: (_, i) => _ProviderCard(
          provider: _providers[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GarageProfileScreen(provider: _providers[i]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return FlutterMap(
      options: MapOptions(initialCenter: _position, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: AppConfig.mapTileUrl,
          userAgentPackageName: AppConfig.mapUserAgent,
        ),
        MarkerLayer(
          markers: _providers.where((p) => p.latitude != null).map((p) {
            return Marker(
              point: LatLng(p.latitude!, p.longitude!),
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 35,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onTap;
  const _ProviderCard({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.store_outlined, color: AppColors.primary),
        ),
        title: Text(
          provider.businessName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.warning, size: 14),
                const SizedBox(width: 4),
                Text(
                  provider.rating?.toStringAsFixed(1) ?? '0.0',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  "${provider.distanceKm?.toStringAsFixed(1) ?? '?'} km",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: StatusBadge.online(provider.isOnline),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
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
  List<Map<String, dynamic>> _serviceTypes = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  int _currentLimit = 10;
  bool _onlineOnly = false;
  int? _selectedServiceType;
  double? _radius = 20.0;
  final TextEditingController _searchCtrl = TextEditingController();

  LatLng _position = const LatLng(9.02497, 38.74689);

  @override
  void initState() {
    super.initState();
    _selectedServiceType = widget.preFilterServiceTypeId;
    _loadServiceTypes();
    _init();
  }

  Future<void> _init() async {
    try {
      Position? lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        _position = LatLng(lastPos.latitude, lastPos.longitude);
      }
      _search();

      Position currentPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 3),
      );
      _position = LatLng(currentPos.latitude, currentPos.longitude);
      _search();
    } catch (_) {
      _search();
    }
  }

  Future<void> _loadServiceTypes() async {
    try {
      _serviceTypes = await sl<HomeRemoteSource>().getServiceTypes();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _search({bool isLoadMore = false}) async {
    if (!mounted) return;
    setState(() {
      if (isLoadMore)
        _loadingMore = true;
      else
        _loading = true;
      _error = null;
    });

    try {
      final results = await sl<HomeRemoteSource>().getNearbyProviders(
        lat: _position.latitude,
        lng: _position.longitude,
        radiusKm: _radius,
        isOnline: _onlineOnly ? true : null,
        serviceTypeId: _selectedServiceType,
        limit: _currentLimit,
      );
      if (mounted)
        setState(() {
          _providers = results;
          _loading = false;
          _loadingMore = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _loadingMore = false;
          _error = "Connection slow. Tap to retry.";
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Explore Garages'), elevation: 0),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _loading
                ? const SkeletonList()
                : _error != null
                ? ErrorView(message: _error!, onRetry: _search)
                : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "Search garages...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) {
                setState(() => _currentLimit = 10);
                _search();
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Online'),
                  selected: _onlineOnly,
                  onSelected: (v) {
                    setState(() {
                      _onlineOnly = v;
                      _currentLimit = 10;
                    });
                    _search();
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _onlineOnly ? Colors.white : Colors.black,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<double?>(
                  value: _radius,
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  items: const [
                    DropdownMenuItem(value: 5.0, child: Text("5 km")),
                    DropdownMenuItem(value: 20.0, child: Text("20 km")),
                    DropdownMenuItem(value: 100.0, child: Text("100 km")),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _radius = v;
                      _currentLimit = 10;
                    });
                    _search();
                  },
                ),
                const SizedBox(width: 8),
                ..._serviceTypes.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type['name'] ?? ''),
                      selected: _selectedServiceType == type['id'],
                      onSelected: (v) {
                        setState(() {
                          _selectedServiceType = v ? type['id'] : null;
                          _currentLimit = 10;
                        });
                        _search();
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedServiceType == type['id']
                            ? Colors.white
                            : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (_providers.isEmpty) return const EmptyView(title: 'No garages found');
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _currentLimit = 10);
        await _search();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _providers.length + 1,
        itemBuilder: (context, i) {
          if (i == _providers.length) {
            return _providers.length >= _currentLimit
                ? Center(
                    child: _loadingMore
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: () {
                              setState(() => _currentLimit += 10);
                              _search(isLoadMore: true);
                            },
                            child: const Text(
                              "See More Garages",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                  )
                : const SizedBox(height: 80);
          }
          final p = _providers[i];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GarageProfileScreen(provider: p),
                ),
              ),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.store_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                p.businessName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${p.rating?.toStringAsFixed(1) ?? '0.0'} ★ • ${p.distanceKm?.toStringAsFixed(1) ?? '?'} km",
              ),
              trailing: StatusBadge.online(p.isOnline),
            ),
          );
        },
      ),
    );
  }
}

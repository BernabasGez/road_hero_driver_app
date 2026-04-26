import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/datasources/home_remote_source.dart';

class TrackingScreen extends StatefulWidget {
  final int requestId;
  final String garageName;
  const TrackingScreen({
    super.key,
    required this.requestId,
    required this.garageName,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Timer? _timer;
  String _status = 'PENDING';
  String? _eta;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // 1. Initial immediate poll
    _poll();
    // 2. Start periodic polling (every 8 seconds per your config)
    _timer = Timer.periodic(AppConfig.trackingPollInterval, (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    try {
      final response = await sl<HomeRemoteSource>().getRequestTracking(
        widget.requestId,
      );

      if (mounted) {
        setState(() {
          // Update status - Ensure we handle case where status might be null
          _status = response['status']?.toString().toUpperCase() ?? _status;

          // Update ETA
          if (response['eta_minutes'] != null) {
            _eta = "${response['eta_minutes']} mins";
          } else if (response['eta'] != null) {
            _eta = response['eta'].toString();
          }

          _loading = false;
        });

        // Stop polling only if it reaches a terminal state
        if (['COMPLETED', 'CANCELLED', 'REJECTED'].contains(_status)) {
          _timer?.cancel();
          debugPrint("Polling stopped: Terminal state $_status reached.");
        }
      }
    } catch (e) {
      debugPrint("Tracking Poll Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Live Status'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const Spacer(),
          // LARGE STATUS ICON
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: AppColors.primary, size: 80),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _statusMessage,
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          StatusBadge.fromRequestStatus(_status),

          // Show ETA only during transit
          if (_eta != null &&
              (_status == 'EN_ROUTE' ||
                  _status == 'ON_THE_WAY' ||
                  _status == 'ACCEPTED')) ...[
            const SizedBox(height: 40),
            Text("Estimated Arrival", style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(
              _eta!,
              style: AppTextStyles.h1.copyWith(
                color: AppColors.actionOrange,
                fontSize: 36,
              ),
            ),
          ],
          const Spacer(),

          // PROVIDER INFO CARD
          _buildInfoCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.store_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.garageName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  "Service Provider",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Call button
          CircleAvatar(
            backgroundColor: Colors.green.shade50,
            child: IconButton(
              icon: const Icon(Icons.phone, color: Colors.green, size: 20),
              onPressed: () {
                // Future: Integration with url_launcher to call provider
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC MAPPING BASED ON BACKEND DOCS ---

  String get _statusMessage => switch (_status) {
    'PENDING' => 'Waiting for the garage to accept your request...',
    'ACCEPTED' => 'The garage has accepted! Preparing tools...',
    'EN_ROUTE' ||
    'ON_THE_WAY' => 'The mechanic is currently on the way to you.',
    'ARRIVED' => 'The mechanic has arrived at your location.',
    'IN_PROGRESS' => 'Work is underway. Fixing your vehicle...',
    'COMPLETED' => 'Service finished! Please proceed to payment.',
    'CANCELLED' => 'This request was cancelled.',
    'REJECTED' => 'The garage could not fulfill this request.',
    _ => 'Updating status...',
  };

  IconData get _statusIcon => switch (_status) {
    'PENDING' => Icons.hourglass_top_rounded,
    'ACCEPTED' => Icons.assignment_turned_in_outlined,
    'EN_ROUTE' || 'ON_THE_WAY' => Icons.local_shipping_outlined,
    'ARRIVED' => Icons.location_on_rounded,
    'IN_PROGRESS' => Icons.build_circle_outlined,
    'COMPLETED' => Icons.check_circle_rounded,
    'CANCELLED' || 'REJECTED' => Icons.cancel_outlined,
    _ => Icons.sync,
  };
}

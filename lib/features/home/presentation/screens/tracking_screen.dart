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
    _poll();
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
          _status = response['status'] ?? _status;
          if (response['eta_minutes'] != null)
            _eta = "${response['eta_minutes']} mins";
          _loading = false;
        });
        if (['COMPLETED', 'CANCELLED'].contains(_status.toUpperCase()))
          _timer?.cancel();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Live Status'), elevation: 0),
      body: Column(
        children: [
          const Spacer(),
          // LARGE STATUS ICON (Replaced the Map)
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon, color: AppColors.primary, size: 70),
          ),
          const SizedBox(height: 32),
          Text(
            _statusMessage,
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          StatusBadge.fromRequestStatus(_status),

          if (_eta != null && _status.toUpperCase() == 'EN_ROUTE') ...[
            const SizedBox(height: 40),
            Text("Estimated Arrival", style: AppTextStyles.caption),
            Text(
              _eta!,
              style: AppTextStyles.h1.copyWith(color: AppColors.actionOrange),
            ),
          ],
          const Spacer(),

          // INFO CARD
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.store_outlined,
                  color: AppColors.primary,
                  size: 28,
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
                AppIconButton(icon: Icons.phone, onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String get _statusMessage => switch (_status.toUpperCase()) {
    'PENDING' => 'Waiting for the garage to accept...',
    'ACCEPTED' => 'Request Accepted!',
    'EN_ROUTE' || 'ON_THE_WAY' => 'Provider is on the way!',
    'ARRIVED' => 'Provider has arrived!',
    'IN_PROGRESS' => 'Fixing your vehicle...',
    'COMPLETED' => 'Service Completed!',
    _ => 'Connecting...',
  };

  IconData get _statusIcon => switch (_status.toUpperCase()) {
    'PENDING' => Icons.hourglass_top,
    'ACCEPTED' => Icons.check_circle_outline,
    'EN_ROUTE' => Icons.local_shipping,
    'ARRIVED' => Icons.location_on,
    'IN_PROGRESS' => Icons.build,
    'COMPLETED' => Icons.verified,
    _ => Icons.sync,
  };
}

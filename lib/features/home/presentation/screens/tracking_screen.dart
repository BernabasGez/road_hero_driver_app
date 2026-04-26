import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart'; // Added this
import '../../data/datasources/home_remote_source.dart';
import 'request_history_detail_screen.dart';

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
  bool _loading = true;
  String? _error;

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
      final data = await sl<HomeRemoteSource>().getRequestTracking(
        widget.requestId,
      );
      if (mounted) {
        setState(() {
          _status = data['status']?.toString().toUpperCase() ?? _status;
          _loading = false;
          _error = null;
        });

        if (_status == 'COMPLETED') {
          _timer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RequestHistoryDetailScreen(requestId: widget.requestId),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              "Unable to connect to the garage. Please check your internet.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Live Status'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? ErrorView(
              message: _error!,
              onRetry: () {
                setState(() => _loading = true);
                _poll();
              },
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildStatusIcon(),
                  const SizedBox(height: 24),
                  Text(
                    _getStatusTitle(),
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "The garage is managing your request. They will call you shortly.",
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  _buildStep(1, "Request Sent", true),
                  _buildStep(2, "Garage Accepted", _status != 'PENDING'),
                  _buildStep(
                    3,
                    "Assistance arriving",
                    [
                      'EN_ROUTE',
                      'ON_THE_WAY',
                      'ARRIVED',
                      'IN_PROGRESS',
                    ].contains(_status),
                  ),

                  const Spacer(),
                  AppButton(
                    label: "Call Garage",
                    icon: Icons.phone,
                    onPressed: () {}, // Integrate phone dialer here
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusIcon() => Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.1),
      shape: BoxShape.circle,
    ),
    child: Icon(
      _status == 'PENDING' ? Icons.access_time : Icons.check_circle_outline,
      color: AppColors.primary,
      size: 40,
    ),
  );

  Widget _buildStep(int nr, String label, bool isDone) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_off,
          color: isDone ? Colors.green : Colors.grey,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isDone ? Colors.black : Colors.grey,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );

  String _getStatusTitle() {
    if (_status == 'PENDING') return "Waiting for Confirmation";
    return "Mechanic is on the way";
  }
}

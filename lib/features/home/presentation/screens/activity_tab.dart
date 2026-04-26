import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/datasources/home_remote_source.dart';
import '../../data/models/service_request_model.dart';
import 'tracking_screen.dart';
import 'request_history_detail_screen.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<ServiceRequestModel> _active = [];
  List<ServiceRequestModel> _history = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // RESTORED: Calling different API groups as per your backend requirement
      final results = await Future.wait([
        sl<HomeRemoteSource>().getRequests(statusGroup: 'active'),
        sl<HomeRemoteSource>().getRequests(statusGroup: 'history'),
      ]);

      if (mounted) {
        setState(() {
          _active = results[0];
          _history = results[1];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load activity. Please try again.";
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
        title: const Text('My Activity', style: AppTextStyles.h2),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: _loading
          ? const SkeletonList()
          : _error != null
          ? ErrorView(message: _error!, onRetry: _load)
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(_active, "No active requests", isHistory: false),
                _buildList(_history, "No history found", isHistory: true),
              ],
            ),
    );
  }

  Widget _buildList(
    List<ServiceRequestModel> items,
    String emptyMsg, {
    required bool isHistory,
  }) {
    if (items.isEmpty) {
      return EmptyView(
        title: emptyMsg,
        icon: isHistory ? Icons.history : Icons.hourglass_empty,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final r = items[i];
          return GestureDetector(
            onTap: () {
              // Navigate based on status
              if (r.isActive) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackingScreen(
                      requestId: r.id,
                      garageName: r.providerName ?? 'Garage',
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RequestHistoryDetailScreen(requestId: r.id),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isHistory ? Icons.check_circle_outline : Icons.car_repair,
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
                          r.providerName ?? 'Assistance Garage',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.serviceType ?? 'General Assistance',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.createdAt?.substring(0, 10) ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.fromRequestStatus(r.status),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
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
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Tab Header ---
        Container(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            MediaQuery.of(context).padding.top + 16,
            AppDimensions.screenPadding,
            0,
          ),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Activity', style: AppTextStyles.h2),
              const SizedBox(height: AppDimensions.md),
              TabBar(
                controller: _tabCtrl,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: 'Active (${_active.length})'),
                  Tab(text: 'History (${_history.length})'),
                ],
              ),
            ],
          ),
        ),

        // --- List Content ---
        Expanded(
          child: _loading
              ? const SkeletonList()
              : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildList(_active, isHistory: false),
                    _buildList(_history, isHistory: true),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildList(
    List<ServiceRequestModel> items, {
    required bool isHistory,
  }) {
    if (items.isEmpty) {
      return EmptyView(
        title: isHistory ? 'No past requests' : 'No active requests',
        subtitle: isHistory
            ? 'Your service history will appear here'
            : 'Request assistance to see your live status here',
        icon: isHistory ? Icons.history : Icons.hourglass_empty_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final r = items[i];

          return GestureDetector(
            // --- THE ONTAP LOGIC YOU WERE LOOKING FOR ---
            onTap: () {
              if (r.isActive) {
                // ACTIVE: Go to Live Status (No map)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackingScreen(
                      requestId: r.id, // mapped from request_id
                      garageName: r.providerName ?? 'Garage',
                    ),
                  ),
                );
              } else {
                // COMPLETED/CANCELLED: Go to Receipt/Review page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RequestHistoryDetailScreen(
                      requestId: r.id, // mapped from request_id
                    ),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.cardSpacing),
              padding: const EdgeInsets.all(AppDimensions.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.build_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                r.providerName ?? 'Garage',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusBadge.fromRequestStatus(r.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.serviceType ?? 'Automotive Service',
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.createdAt?.substring(0, 10) ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

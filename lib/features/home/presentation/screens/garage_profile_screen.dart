import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../data/datasources/home_remote_source.dart';
import '../../data/models/provider_model.dart';
import 'request_details_screen.dart';

class GarageProfileScreen extends StatefulWidget {
  final ProviderModel provider;
  const GarageProfileScreen({super.key, required this.provider});

  @override
  State<GarageProfileScreen> createState() => _GarageProfileScreenState();
}

class _GarageProfileScreenState extends State<GarageProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProviderModel? _detail;
  bool _loadingDetail = true;
  List<Map<String, dynamic>> _spareParts = [];
  bool _loadingParts = false;
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadDetail();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1 && _spareParts.isEmpty)
      _loadSpareParts();
    else if (_tabController.index == 2 && _reviews.isEmpty)
      _loadReviews();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await sl<HomeRemoteSource>().getProviderDetail(
        widget.provider.id,
      );
      if (mounted)
        setState(() {
          _detail = detail;
          _loadingDetail = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _detail = widget.provider;
          _loadingDetail = false;
        });
    }
  }

  Future<void> _loadSpareParts() async {
    setState(() => _loadingParts = true);
    try {
      final parts = await sl<HomeRemoteSource>().getProviderSpareParts(
        widget.provider.id,
      );
      if (mounted)
        setState(() {
          _spareParts = parts;
          _loadingParts = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingParts = false);
    }
  }

  Future<void> _loadReviews() async {
    setState(() => _loadingReviews = true);
    try {
      final reviews = await sl<HomeRemoteSource>().getProviderReviews(
        widget.provider.id,
      );
      if (mounted)
        setState(() {
          _reviews = reviews;
          _loadingReviews = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _detail ?? widget.provider;
    return Scaffold(
      // FIX: Changed background to White to remove grey gap
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                // Maintain grey header look
                backgroundColor: const Color(0xFF6B7280),
                elevation: 0,
                leading: _buildCircleAction(
                  Icons.arrow_back,
                  () => Navigator.pop(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.businessName, style: AppTextStyles.h2),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildBadge(
                            Icons.verified,
                            "Verified",
                            AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            Icons.star,
                            "Expert",
                            Colors.grey.shade600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: AppColors.actionOrange,
                        labelColor: AppColors.actionOrange,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: "Services"),
                          Tab(text: "Spare Parts"),
                          Tab(text: "Reviews"),
                          Tab(text: "Info"),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) => _buildTabContent(p),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: AppButton(
                  label: 'Request Service',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestDetailsScreen(provider: p),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ProviderModel p) {
    switch (_tabController.index) {
      case 0:
        return Column(
          children: [
            _buildPriceItem(
              "General Repair",
              "Varies by issue",
              "Check with garage",
            ),
          ],
        );
      case 1:
        return _loadingParts
            ? const Center(child: CircularProgressIndicator())
            : _spareParts.isEmpty
            ? const EmptyView(title: "No parts listed")
            : Column(
                children: _spareParts
                    .map(
                      (part) => _buildPriceItem(
                        part['name'] ?? 'Part',
                        part['category'] ?? 'Spare',
                        "${part['price'] ?? '0'} ETB",
                      ),
                    )
                    .toList(),
              );
      case 2:
        return _buildReviewsView(p);
      case 3:
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(p.phone ?? 'Not provided'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildReviewsView(ProviderModel p) {
    if (_loadingReviews)
      return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.warning, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${p.rating?.toStringAsFixed(1) ?? '0.0'}/5.0",
                  style: AppTextStyles.h2,
                ),
                Text(
                  "Based on ${p.reviewCount ?? 0} ratings",
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
        const Divider(height: 40),
        if (_reviews.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("No detailed reviews yet."),
            ),
          )
        else
          ..._reviews.map((rev) => _buildReviewItem(rev)),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> rev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  (rev['user_name'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                rev['user_name'] ?? 'Verified User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 12,
                    color: index < (rev['rating'] ?? 0)
                        ? AppColors.warning
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rev['comment'] ?? 'No comment.',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.all(8),
    child: CircleAvatar(
      backgroundColor: Colors.white,
      child: IconButton(
        icon: Icon(icon, color: Colors.black, size: 20),
        onPressed: onTap,
      ),
    ),
  );

  Widget _buildBadge(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _buildPriceItem(String t, String d, String p) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(d, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        Text(
          p,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}

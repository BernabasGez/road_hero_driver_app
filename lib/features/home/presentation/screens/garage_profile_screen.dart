import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this for date formatting
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

  // Data for dynamic tabs
  List<Map<String, dynamic>> _spareParts = [];
  bool _loadingParts = false;

  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = false;

  bool _isFavorite = false;

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

  // TRIGGER BACKEND CALLS WHEN TABS ARE CLICKED
  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    if (_tabController.index == 1 && _spareParts.isEmpty) {
      _loadSpareParts();
    } else if (_tabController.index == 2 && _reviews.isEmpty) {
      _loadReviews();
    }
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await sl<HomeRemoteSource>()
          .getProviderDetail(widget.provider.id)
          .timeout(const Duration(seconds: 8));
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
      // Calls the new method we added to the DataSource
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

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await sl<HomeRemoteSource>().removeFavorite(widget.provider.id);
      } else {
        await sl<HomeRemoteSource>().addFavorite(widget.provider.id);
      }
      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _detail ?? widget.provider;

    return Scaffold(
      backgroundColor: const Color(0xFF6B7280),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // --- Header Section ---
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: _buildCircleAction(
                  Icons.arrow_back,
                  () => Navigator.pop(context),
                ),
                actions: [
                  _buildCircleAction(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    _toggleFavorite,
                    color: _isFavorite ? AppColors.error : Colors.black,
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(
                        Icons.store_outlined,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),
              ),

              // --- Main Card ---
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            p.address ?? "Bole, Addis Ababa",
                            style: AppTextStyles.bodySmall,
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
                        labelStyle: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: "Services"),
                          Tab(text: "Spare Parts"),
                          Tab(text: "Reviews"),
                          Tab(text: "Info"),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // AnimatedBuilder makes sure the content UI refreshes when _tabController changes
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

          // --- Bottom Buttons (Fixed Overflow) ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Call',
                        variant: AppButtonVariant.secondary,
                        icon: Icons.phone_outlined,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: AppButton(
                        label: 'Request Service',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RequestDetailsScreen(provider: p),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
        return _buildServicesView(p);
      case 1:
        return _buildSparePartsView();
      case 2:
        return _buildReviewsView(p);
      case 3:
        return _buildInfoView(p);
      default:
        return const SizedBox();
    }
  }

  Widget _buildServicesView(ProviderModel p) {
    // If backend doesn't provide prices, show defaults
    return Column(
      children: [
        _buildPriceItem("Oil Change", "Includes filter & labor", "1,500 ETB"),
        _buildPriceItem("Diagnostics", "Full system scan", "500 ETB"),
        _buildPriceItem("Brake Repair", "Labor only", "800 ETB"),
        _buildPriceItem("Engine Tune-up", "Spark plugs & filter", "2,000 ETB"),
      ],
    );
  }

  Widget _buildSparePartsView() {
    if (_loadingParts)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );
    if (_spareParts.isEmpty)
      return const EmptyView(
        title: "No spare parts",
        subtitle: "This garage hasn't uploaded inventory.",
      );
    return Column(
      children: _spareParts
          .map(
            (part) => _buildPriceItem(
              part['name'] ?? 'Part',
              part['category'] ?? 'Spare Part',
              "${part['price'] ?? '0'} ETB",
            ),
          )
          .toList(),
    );
  }

  Widget _buildReviewsView(ProviderModel p) {
    if (_loadingReviews)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Use Expanded for the title so the button has a fixed width
            Expanded(
              child: Text("User Reviews", style: AppTextStyles.sectionHeader),
            ),
            const SizedBox(width: 8),
            AppButton(
              label: "Rate Now",
              size: AppButtonSize.small,
              width: 95, // Set a specific width that fits your screen
              onPressed: () => _showWriteReviewDialog(p.id),
            ),
          ],
        ),
        const Divider(height: 32),
        if (_loadingReviews)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          const Center(child: Text("No reviews yet."))
        else
          ..._reviews.map((rev) => _buildReviewItem(rev)),
      ],
    );
  }

  // POP-UP DIALOG FOR WRITING A REVIEW
  void _showWriteReviewDialog(int providerId) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Rate this Garage"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FIXED OVERFLOW: FittedBox ensures stars fit on narrow screens like Infinix
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      constraints: const BoxConstraints(),
                      onPressed: isSubmitting
                          ? null
                          : () => setDialogState(
                              () => selectedRating = index + 1,
                            ),
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                enabled: !isSubmitting,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Share your experience...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      try {
                        await sl<HomeRemoteSource>().submitGarageReview(
                          providerId: providerId,
                          rating: selectedRating,
                          comment: commentController.text,
                        );
                        if (mounted) {
                          Navigator.pop(ctx);
                          _loadReviews();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Review submitted!"),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> rev) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                rev['user_name'] ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
          const SizedBox(height: 4),
          Text(rev['comment'] ?? '', style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          if (rev['created_at'] != null)
            Text(
              rev['created_at'].toString().substring(0, 10),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoView(ProviderModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contact Info",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.phone, size: 18),
          title: Text(p.phone ?? 'Not provided'),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          leading: const Icon(Icons.access_time, size: 18),
          title: const Text('Open 8:00 AM - 6:00 PM'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  // UI Reusable Helpers
  Widget _buildCircleAction(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(icon, color: color, size: 20),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
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
  }

  Widget _buildPriceItem(String title, String desc, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

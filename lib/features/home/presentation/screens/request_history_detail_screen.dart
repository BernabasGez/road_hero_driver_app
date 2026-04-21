import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/datasources/home_remote_source.dart';
import '../../data/models/service_request_model.dart';

class RequestHistoryDetailScreen extends StatefulWidget {
  final int requestId;
  const RequestHistoryDetailScreen({super.key, required this.requestId});

  @override
  State<RequestHistoryDetailScreen> createState() =>
      _RequestHistoryDetailScreenState();
}

class _RequestHistoryDetailScreenState
    extends State<RequestHistoryDetailScreen> {
  ServiceRequestModel? _request;
  bool _loading = true;

  // Review Form State
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  final List<String> _selectedTags = [];
  bool _submittingReview = false;

  // Available tags from backend documentation
  final List<String> _availableTags = [
    'fast_service',
    'professional',
    'friendly',
    'fair_price',
    'expert',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await sl<HomeRemoteSource>().getRequestDetail(widget.requestId);
      setState(() {
        _request = r;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }

    setState(() => _submittingReview = true);
    try {
      await sl<HomeRemoteSource>().submitReview(
        requestId: widget.requestId, // Fixes the red squiggle
        rating: _rating,
        comment: _commentCtrl.text.trim(),
        tags: _selectedTags,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your review!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Return to activity list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submittingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Service Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _request == null
          ? const Center(child: Text('Request details not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),

                  // ONLY SHOW REVIEW SECTION IF COMPLETED
                  if (_request!.status.toUpperCase() == 'COMPLETED') ...[
                    const SizedBox(height: 24),
                    _buildReviewSection(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _request!.providerName ?? 'Garage', // Changed to match
                  style: AppTextStyles.h3,
                ),
              ),
              StatusBadge.fromRequestStatus(_request!.status),
            ],
          ),
          const Divider(height: 24),
          _infoRow('Service', _request!.serviceType ?? 'General Repair'),
          _infoRow('Vehicle', _request!.vehicleName ?? 'My Vehicle'),
          _infoRow('Date', _request!.createdAt?.substring(0, 10) ?? 'N/A'),
          if (_request!.description != null)
            _infoRow('Issue', _request!.description!),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rate your experience",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Stars Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: AppColors.warning,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tags (Documentation mentions: fast_service, professional, friendly)
          Wrap(
            spacing: 8,
            children: ['fast_service', 'professional', 'friendly'].map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return ChoiceChip(
                label: Text(
                  tag.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 11),
                ),
                selected: isSelected,
                onSelected: (val) {
                  setState(
                    () => val
                        ? _selectedTags.add(tag)
                        : _selectedTags.remove(tag),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentCtrl,
            decoration: const InputDecoration(
              hintText: "Add a comment...",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: "Submit Review",
            isLoading: _submittingReview,
            onPressed: () async {
              if (_rating == 0) return;
              setState(() => _submittingReview = true);
              try {
                await sl<HomeRemoteSource>().submitReview(
                  requestId: widget.requestId,
                  rating: _rating,
                  tags: _selectedTags,
                  comment: _commentCtrl.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Thank you!")));
              } catch (e) {
                setState(() => _submittingReview = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: AppTextStyles.caption)),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

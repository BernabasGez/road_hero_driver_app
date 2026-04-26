import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  final List<String> _selectedTags = [];
  bool _submittingReview = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Service Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _request == null
          ? const Center(child: Text('Request not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCard(),
                  if (_request!.status.toUpperCase() == 'COMPLETED') ...[
                    const SizedBox(height: 24),
                    // Check if rating exists to show "Your Feedback"
                    (_request!.rating != null && _request!.rating! > 0)
                        ? _buildExistingReview()
                        : _buildReviewForm(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _request!.providerName ?? 'Garage',
                  style: AppTextStyles.h3,
                ),
              ),
              StatusBadge.fromRequestStatus(_request!.status),
            ],
          ),
          const Divider(height: 32),
          _infoRow('Service', _request!.serviceType ?? 'General'),
          _infoRow('Vehicle', _request!.vehicleName ?? 'Vehicle'),
          _infoRow('Date', _request!.createdAt?.substring(0, 10) ?? ''),
          if (_request!.description != null)
            _infoRow('Issue', _request!.description!),
        ],
      ),
    );
  }

  Widget _buildExistingReview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Feedback",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 18,
                    color: i < (_request!.rating ?? 0)
                        ? Colors.orange
                        : Colors.grey[200],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _request!.reviewComment ?? "No written comment was provided.",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            "Rate your experience",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => IconButton(
                onPressed: () => setState(() => _rating = i + 1),
                icon: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Add a comment...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                _load();
              } catch (e) {
                setState(() => _submittingReview = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String l, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            l,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(child: Text(v, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );
}

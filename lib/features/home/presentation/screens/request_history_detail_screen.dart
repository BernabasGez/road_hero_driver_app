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
  String _selectedPayment = "Telebirr";

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
      appBar: AppBar(
        title: const Text('Invoice Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _request == null
            ? const Center(child: Text('Receipt could not be loaded'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Completion Header
                    _buildStatusHeader(),
                    const SizedBox(height: 20),

                    // Invoice Content
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "SERVICE SUMMARY",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _row("Provider", _request!.providerName ?? "Garage"),
                          _row("Vehicle", _request!.vehicleName ?? "-"),
                          _row("Service", _request!.serviceType ?? "-"),
                          _row("Status", _request!.status, isStatus: true),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(
                              thickness: 1,
                              color: AppColors.background,
                            ),
                          ),

                          const Text(
                            "BILLING DETAILS",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_request!.spareParts.isNotEmpty) ...[
                            ..._request!.spareParts.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${item.quantity}x ${item.name}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      "${item.total.toStringAsFixed(0)} ETB",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 32),
                          ],

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "TOTAL AMOUNT",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "${_calculateTotal().toStringAsFixed(0)} ETB",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment Shell (Ready for backend logic)
                    if (_request!.status == 'COMPLETED') ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Payment Method",
                          style: AppTextStyles.label,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentSelector(),
                      const SizedBox(height: 32),
                      AppButton(
                        label: "Proceed to Payment",
                        onPressed: () => _handlePayment(context),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  double _calculateTotal() {
    double parts = _request!.spareParts.fold(
      0,
      (sum, item) => sum + item.total,
    );
    double serviceFee = 500; // Placeholder base fee
    return parts + serviceFee;
  }

  Widget _buildStatusHeader() => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    decoration: BoxDecoration(
      color: AppColors.success.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline, color: AppColors.success),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "Repair Completed Successfully",
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPaymentSelector() => Row(
    children: ["Telebirr", "Chapa", "Cash"].map((method) {
      bool isSelected = _selectedPayment == method;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedPayment = method),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                method,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );

  void _handlePayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.payment, color: AppColors.primary, size: 48),
        content: const Text(
          "Redirecting to secure payment provider. Please confirm the transaction on your device.",
          textAlign: TextAlign.center,
        ),
        actions: [
          AppButton(
            label: "Back to Dashboard",
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  Widget _row(String l, String v, {bool isStatus = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        isStatus
            ? StatusBadge.fromRequestStatus(v)
            : Text(
                v,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
      ],
    ),
  );
}

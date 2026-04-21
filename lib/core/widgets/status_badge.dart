import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = StatusType.neutral,
  });

  factory StatusBadge.fromRequestStatus(String status) {
    final type = switch (status.toUpperCase()) {
      'PENDING' => StatusType.warning,
      'ACCEPTED' => StatusType.info,
      'EN_ROUTE' => StatusType.info,
      'ARRIVED' => StatusType.success,
      'IN_PROGRESS' => StatusType.success,
      'COMPLETED' => StatusType.success,
      'CANCELLED' => StatusType.error,
      _ => StatusType.neutral,
    };
    return StatusBadge(text: _formatStatus(status), type: type);
  }

  factory StatusBadge.online(bool isOnline) {
    return StatusBadge(
      text: isOnline ? 'Open' : 'Closed',
      type: isOnline ? StatusType.success : StatusType.neutral,
    );
  }

  static String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (type) {
      StatusType.success => (AppColors.successBg, AppColors.success),
      StatusType.warning => (AppColors.warningBg, AppColors.warning),
      StatusType.error => (AppColors.errorBg, AppColors.error),
      StatusType.info => (const Color(0x1A1E3A8A), AppColors.primary),
      StatusType.neutral => (AppColors.border, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

enum StatusType { success, warning, error, info, neutral }

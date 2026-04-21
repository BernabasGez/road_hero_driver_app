import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';
import 'app_button.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    this.message = 'Something went wrong. Please try again.',
    this.actionLabel,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppDimensions.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.lg),
              AppButton(
                label: actionLabel ?? 'Try Again',
                onPressed: onRetry,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.medium,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyView({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: AppColors.border),
            const SizedBox(height: AppDimensions.md),
            Text(title, style: AppTextStyles.sectionHeader, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.sm),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppDimensions.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AppButtonSize.medium,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

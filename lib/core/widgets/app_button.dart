import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, text }

enum AppButtonSize { large, medium, small }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      AppButtonSize.large => AppDimensions.buttonHeight,
      AppButtonSize.medium => 44.0,
      AppButtonSize.small => 36.0,
    };

    final fontSize = switch (size) {
      AppButtonSize.large => 16.0,
      AppButtonSize.medium => 14.0,
      AppButtonSize.small => 13.0,
    };

    final child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == AppButtonVariant.secondary
                  ? AppColors.primary
                  : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // Center the content
            children: [
              if (icon != null) ...[
                Icon(icon, size: fontSize + 4),
                const SizedBox(width: 8),
              ],
              // Wrap text in Flexible to prevent "RenderFlex overflow"
              Flexible(
                child: Text(
                  label,
                  overflow:
                      TextOverflow.ellipsis, // Add dots if text is too long
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ],
          );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: switch (variant) {
        AppButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.disabled,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
            elevation: 0,
          ),
          child: child,
        ),
        AppButtonVariant.secondary => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
          ),
          child: child,
        ),
        AppButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
          ),
          child: child,
        ),
      },
    );
  }
}

/// Circular icon button (44px) per design spec
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = AppDimensions.iconButtonSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.border,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
    );
  }
}

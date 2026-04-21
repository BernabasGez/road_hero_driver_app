import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final int? maxLength;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.sm),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: textInputAction,
          maxLength: maxLength,
          style: AppTextStyles.input,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.inputHint,
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
            filled: true,
            fillColor: enabled ? AppColors.inputFill : AppColors.border,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}

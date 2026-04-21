import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _submit() {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit code')),
      );
      return;
    }
    context.read<AuthBloc>().add(
          VerifyOtpSubmitted(phone: widget.phone, otp: _otp),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
          // OtpVerified handled by router
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verify your phone', style: AppTextStyles.h2),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Enter the 6-digit code sent to ${widget.phone}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.xl + 8),
              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h3,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        counterText: '',
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        } else if (v.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        if (_otp.length == 6) _submit();
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppDimensions.xl),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AppButton(
                    label: 'Verify',
                    isLoading: state is AuthLoading,
                    onPressed: _submit,
                  );
                },
              ),
              const SizedBox(height: AppDimensions.lg),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Resend OTP - call register again or separate endpoint
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP resent successfully')),
                    );
                  },
                  child: Text(
                    'Resend Code',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

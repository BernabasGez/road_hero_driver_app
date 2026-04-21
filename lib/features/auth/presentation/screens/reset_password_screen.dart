import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  final VoidCallback onSuccess;
  const ResetPasswordScreen({super.key, required this.phone, required this.onSuccess});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          ResetPasswordSubmitted(
            phone: widget.phone,
            otp: _otpCtrl.text.trim(),
            newPassword: _passCtrl.text,
          ),
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
          if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successfully! Please sign in.'),
                backgroundColor: AppColors.success,
              ),
            );
            widget.onSuccess();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reset password', style: AppTextStyles.h2),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'Enter the code sent to ${widget.phone} and your new password.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.xl),
                AppTextField(
                  controller: _otpCtrl,
                  label: 'Verification Code',
                  hint: '6-digit code',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  prefix: const Icon(Icons.pin_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().length != 6) return 'Enter 6-digit code';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),
                AppTextField(
                  controller: _passCtrl,
                  label: 'New Password',
                  hint: 'Enter new password',
                  obscureText: _obscure,
                  prefix: const Icon(Icons.lock_outline, size: 20),
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textHint,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),
                AppTextField(
                  controller: _confirmCtrl,
                  label: 'Confirm Password',
                  hint: 'Re-enter password',
                  obscureText: true,
                  prefix: const Icon(Icons.lock_outline, size: 20),
                  validator: (v) {
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.lg),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppButton(
                      label: 'Reset Password',
                      isLoading: state is AuthLoading,
                      onPressed: _submit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

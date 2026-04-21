import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final void Function(String phone) onOtpSent;

  const ForgotPasswordScreen({super.key, required this.onOtpSent});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          ForgotPasswordSubmitted(phone: _phoneCtrl.text.trim()),
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
          if (state is ForgotPasswordSent) {
            widget.onOtpSent(state.phone);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Forgot password?', style: AppTextStyles.h2),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  "Enter your phone number and we'll send you a code to reset your password.",
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.xl),
                AppTextField(
                  controller: _phoneCtrl,
                  label: 'Phone number',
                  hint: '+251 9XX XXX XXXX',
                  keyboardType: TextInputType.phone,
                  prefix: const Icon(Icons.phone_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone number is required';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.lg),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppButton(
                      label: 'Send Reset Code',
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

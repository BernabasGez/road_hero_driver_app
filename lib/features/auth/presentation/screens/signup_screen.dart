import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final void Function(String phone) onRegistered;

  const SignupScreen({super.key, required this.onLogin, required this.onRegistered});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          RegisterSubmitted(
            phone: _phoneCtrl.text.trim(),
            name: _nameCtrl.text.trim(),
            password: _passCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is RegistrationSuccess) {
              widget.onRegistered(state.phone);
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
                  const SizedBox(height: AppDimensions.xxl),
                  const Text('Create Account', style: AppTextStyles.h1),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Join RoadHero for instant roadside help',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimensions.xl + 8),
                  AppTextField(
                    controller: _nameCtrl,
                    label: 'Full name',
                    hint: 'Abebe Kebede',
                    prefix: const Icon(Icons.person_outline, size: 20),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Name is required';
                      if (v.trim().length < 2) return 'Enter your full name';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AppTextField(
                    controller: _phoneCtrl,
                    label: 'Phone number',
                    hint: '+251 9XX XXX XXXX',
                    keyboardType: TextInputType.phone,
                    prefix: const Icon(Icons.phone_outlined, size: 20),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Phone number is required';
                      if (v.trim().length < 10) return 'Enter a valid phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AppTextField(
                    controller: _passCtrl,
                    label: 'Password',
                    hint: 'Create a strong password',
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
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 8) return 'Password must be at least 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.lg + 8),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        label: 'Create Account',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: widget.onLogin,
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

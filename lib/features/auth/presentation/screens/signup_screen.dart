import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:road_hero/features/auth/presentation/screens/otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OtpVerificationScreen(phoneNumber: _phoneController.text),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildLabel("Full Name"),
                  TextField(
                    controller: _nameController,
                    decoration: _inputDeco("Abebe Kebede"),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Phone Number"),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDeco("911 234 567").copyWith(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text(
                          "🇪🇹 +251 ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Password"),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDeco("••••••••"),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                SignUpSubmitted(
                                  _nameController.text,
                                  "+251${_phoneController.text}",
                                  _passwordController.text,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Send Code",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
  );
}

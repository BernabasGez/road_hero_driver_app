import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Using Package Import to fix the SL error
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:road_hero/features/home/presentation/screens/home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<AuthBloc>(), // sl will now be recognized correctly
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Verify Phone Number",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter the 6-digit code sent to ${widget.phoneNumber}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => _buildOtpBox(index)),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              String otp = _controllers
                                  .map((e) => e.text)
                                  .join();
                              if (otp.length < 6) return;
                              context.read<AuthBloc>().add(
                                VerifyOtpSubmitted(widget.phoneNumber, otp),
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
                              "Verify & Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
        },
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

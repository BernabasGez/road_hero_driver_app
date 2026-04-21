import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_hero/features/home/presentation/bloc/home_cubit.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/auth/presentation/screens/otp_verification_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/reset_password_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const RoadHeroApp());
}

class RoadHeroApp extends StatelessWidget {
  const RoadHeroApp({super.key});

  // lib/main.dart

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // 1. We changed this from BlocProvider to MultiBlocProvider
      providers: [
        // 2. We put both Auth and Home controllers here at the top
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<HomeCubit>()),
      ],
      child: MaterialApp(
        title: 'RoadHero',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AppNavigator(),
      ),
    );
  }
}

class _AppNavigator extends StatefulWidget {
  const _AppNavigator();

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle global auth state transitions
      },
      builder: (context, state) {
        // Debug print to see what is happening in your terminal
        print("Current Auth State: $state");

        return Navigator(
          pages: [
            // 1. Splash Screen
            if (state is AuthInitial) const MaterialPage(child: SplashScreen()),

            // 2. Loading Screen (Prevents falling back to Login while waiting for API)
            if (state is AuthLoading)
              const MaterialPage(
                child: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              ),

            // 3. Login/Signup Screen (Only show if explicitly unauthenticated)
            if (state is Unauthenticated || state is AuthError)
              MaterialPage(
                key: const ValueKey('LoginPage'),
                child: LoginScreen(
                  onSignup: () => _push(context, _AuthMode.signup),
                  onForgotPassword: () => _push(context, _AuthMode.forgot),
                ),
              ),

            // 4. Home Screen (Only show if authenticated)
            if (state is Authenticated || state is OtpVerified)
              const MaterialPage(
                key: ValueKey('HomePage'),
                child: HomeScreen(),
              ),
          ],
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        );
      },
    );
  }

  void _push(BuildContext context, _AuthMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: switch (mode) {
            _AuthMode.login => LoginScreen(
              onSignup: () => _push(context, _AuthMode.signup),
              onForgotPassword: () => _push(context, _AuthMode.forgot),
            ),
            _AuthMode.signup => SignupScreen(
              onLogin: () => Navigator.pop(context),
              onRegistered: (phone) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AuthBloc>(),
                      child: OtpVerificationScreen(phone: phone),
                    ),
                  ),
                );
              },
            ),
            _AuthMode.forgot => ForgotPasswordScreen(
              onOtpSent: (phone) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AuthBloc>(),
                      child: ResetPasswordScreen(
                        phone: phone,
                        onSuccess: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          },
        ),
      ),
    );
  }
}

enum _AuthMode { login, signup, forgot }

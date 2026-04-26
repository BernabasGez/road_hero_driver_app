import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added this here at the top
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:road_hero/features/home/presentation/bloc/home_cubit.dart';
import 'package:road_hero/features/home/presentation/bloc/cart_cubit.dart';
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
import 'features/auth/presentation/screens/auth_entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const RoadHeroApp());
}

class RoadHeroApp extends StatelessWidget {
  const RoadHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<HomeCubit>()),
        BlocProvider(create: (_) => sl<CartCubit>()),
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated || state is OtpVerified) {
          _navigatorKey.currentState?.popUntil((route) => route.isFirst);
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final NavigatorState? navigator = _navigatorKey.currentState;
            if (navigator != null && navigator.canPop()) {
              navigator.pop();
            } else {
              _showExitDialog(context);
            }
          },
          child: Navigator(
            key: _navigatorKey,
            pages: [
              if (state is AuthInitial)
                const MaterialPage(child: SplashScreen())
              else if (state is Unauthenticated || state is AuthError)
                const MaterialPage(child: AuthEntryScreen())
              else if (state is Authenticated || state is OtpVerified)
                const MaterialPage(
                  key: ValueKey('HomePage'),
                  child: HomeScreen(),
                )
              else
                const MaterialPage(
                  child: Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
            onPopPage: (route, result) => route.didPop(result),
          ),
        );
      },
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit RoadHero?"),
        content: const Text("Are you sure you want to close the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(), // Fixed the error here
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }
}

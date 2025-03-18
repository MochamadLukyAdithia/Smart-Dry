import 'package:go_router/go_router.dart';
import 'package:smart_dry/features/auth/screen/login_screen.dart';
import 'package:smart_dry/features/auth/screen/register_screen.dart';
import 'package:smart_dry/features/home/screen/home_screen.dart';
import 'package:smart_dry/features/splash/screen/splash_screen.dart';
import 'package:smart_dry/main.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MyApp(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => ThermostatScreen(),
    ),
  ],
);

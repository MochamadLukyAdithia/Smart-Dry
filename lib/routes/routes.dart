import 'package:go_router/go_router.dart';
import 'package:smart_dry/features/auth/screen/login_screen.dart';
import 'package:smart_dry/features/auth/screen/register_screen.dart';
import 'package:smart_dry/features/home/screen/home_screen.dart';
import 'package:smart_dry/features/kadar_air/view/kadar_air_screen.dart';
import 'package:smart_dry/features/notifikasi/screen/notifikasi_screen.dart';
import 'package:smart_dry/features/setting/screen/setting_screen.dart';
import 'package:smart_dry/features/splash/screen/splash_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/kadar_air',
      builder: (context, state) => KadarAirScreen(),
    ),
    GoRoute(
      path: '/setting',
      builder: (context, state) => SettingScreen(),
    ),
    GoRoute(
      path: '/notifikasi',
      builder: (context, state) => NotifikasiScreen(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const ThermostatScreen(),
    ),
  ],
);

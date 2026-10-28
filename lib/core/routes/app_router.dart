import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/capture_page.dart';
import '../../features/auth/presentation/pages/choose_language_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/screens/camerawork/camera_scan_screen.dart';
import '../../features/screens/dashboard.dart';
import '../../features/screens/home_screen.dart';
import '../../features/screens/reset_password_screen.dart';
import '../../features/screens/widgets/hand_capture_graphic.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.initial,
        redirect: (context, state) => AppRoutes.splash,
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.languageSelection,
        builder: (context, state) => const ChooseLanguagePage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Capture page: the scan mode arrives through `extra`
      GoRoute(
        path: AppRoutes.capture,
        builder: (context, state) => CapturePage(
          scanMode: (state.extra as String?) ?? 'thumb_4finger',
        ),
      ),

      // Camera screen: receives a map from CapturePage
      GoRoute(
        path: AppRoutes.cameraScan,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CameraScanScreen(
            title: extra['title'] as String? ?? 'Left Thumb',
            type: extra['type'] as HandCaptureType? ?? HandCaptureType.leftThumb,
            scanMode: extra['scanMode'] as String? ?? 'thumb_4finger',
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('No route defined for ${state.uri}')),
    ),
  );
}

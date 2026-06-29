import 'package:eventix/features/auth/presentation/pages/auth_success_page.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/auth/presentation/pages/new_password_page.dart';
import 'package:eventix/features/auth/presentation/pages/register_page.dart';
import 'package:eventix/features/auth/presentation/pages/reset_password_request_page.dart';
import 'package:eventix/features/auth/presentation/pages/verify_code_page.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> authRoutes = <RouteBase>[
  GoRoute(
    path: LoginPage.routePath,
    builder: (BuildContext context, GoRouterState state) => const LoginPage(),
  ),
  GoRoute(
    path: RegisterPage.routePath,
    builder: (BuildContext context, GoRouterState state) =>
        const RegisterPage(),
  ),
  GoRoute(
    path: VerifyCodePage.routePath,
    builder: (BuildContext context, GoRouterState state) {
      final VerifyCodeArgs? args = state.extra as VerifyCodeArgs?;
      if (args == null) return const LoginPage();
      return VerifyCodePage(args: args);
    },
  ),
  GoRoute(
    path: ResetPasswordRequestPage.routePath,
    builder: (BuildContext context, GoRouterState state) =>
        const ResetPasswordRequestPage(),
  ),
  GoRoute(
    path: NewPasswordPage.routePath,
    builder: (BuildContext context, GoRouterState state) =>
        const NewPasswordPage(),
  ),
  GoRoute(
    path: AuthSuccessPage.routePath,
    builder: (BuildContext context, GoRouterState state) {
      final AuthSuccessArgs? args = state.extra as AuthSuccessArgs?;
      if (args == null) return const LoginPage();
      return AuthSuccessPage(args: args);
    },
  ),
  GoRoute(
    path: OnboardingPage.routePath,
    builder: (BuildContext context, GoRouterState state) =>
        const OnboardingPage(),
  ),
];

import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';

extension PostAuthDestinationRouting on PostAuthDestination {
  String get routePath => switch (this) {
    PostAuthDestination.login => LoginPage.routePath,
    PostAuthDestination.home => EventsPage.routePath,
    PostAuthDestination.onboarding => OnboardingPage.routePath,
  };
}

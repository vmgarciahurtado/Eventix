class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.onboardingCompleted,
  });

  final String id;
  final String firstName;
  final String lastName;
  final bool onboardingCompleted;
}

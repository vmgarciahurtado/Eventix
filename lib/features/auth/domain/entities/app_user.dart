/// Usuario de la app, construido a partir del perfil (`profiles`) en Supabase.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.onboardingCompleted,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool onboardingCompleted;

  String get fullName => '$firstName $lastName'.trim();
}

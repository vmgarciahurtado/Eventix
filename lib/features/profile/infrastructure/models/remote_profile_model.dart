/// Fila de la tabla `profiles`.
class RemoteProfileModel {
  const RemoteProfileModel({
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
}

/// Fila de la tabla `profiles`.
class RemoteProfileModel {
  const RemoteProfileModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.onboardingCompleted,
  });

  factory RemoteProfileModel.fromJson(Map<String, dynamic> json) =>
      RemoteProfileModel(
        id: json['id'] as String,
        email: (json['email'] as String?) ?? '',
        firstName: (json['first_name'] as String?) ?? '',
        lastName: (json['last_name'] as String?) ?? '',
        onboardingCompleted: (json['onboarding_completed'] as bool?) ?? false,
      );

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool onboardingCompleted;
}

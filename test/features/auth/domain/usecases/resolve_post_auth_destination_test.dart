import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/auth/domain/usecases/resolve_post_auth_destination.dart';
import 'package:eventix/features/profile/domain/entities/app_user.dart';
import 'package:eventix/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

AppUser _user({required bool onboardingCompleted}) => AppUser(
  id: 'user-1',
  firstName: 'Victor',
  lastName: 'García',
  onboardingCompleted: onboardingCompleted,
);

void main() {
  late _MockProfileRepository repository;
  late ResolvePostAuthDestination usecase;

  setUp(() {
    repository = _MockProfileRepository();
    usecase = ResolvePostAuthDestination(repository);
  });

  void mockProfile(Result<AppUser?> result) =>
      when(repository.currentProfile).thenAnswer((_) async => result);

  test('con onboarding completado va al catálogo', () async {
    mockProfile(Success<AppUser?>(_user(onboardingCompleted: true)));

    expect(await usecase.call(), PostAuthDestination.home);
  });

  test('con onboarding pendiente va al onboarding', () async {
    mockProfile(Success<AppUser?>(_user(onboardingCompleted: false)));

    expect(await usecase.call(), PostAuthDestination.onboarding);
  });

  test('sin sesión va al login', () async {
    mockProfile(const FailureResult<AppUser?>(UnauthorizedFailure()));

    expect(await usecase.call(), PostAuthDestination.login);
  });

  test('un perfil nulo con sesión válida entra al catálogo', () async {
    // Hay sesión pero la fila de profiles todavía no existe: dejar al usuario
    // repitiendo el onboarding sería peor que dejarlo entrar.
    mockProfile(const Success<AppUser?>(null));

    expect(await usecase.call(), PostAuthDestination.home);
  });

  test('un fallo que no es de sesión no lo expulsa al login', () async {
    // Sin red, la sesión guardada sigue siendo válida: mandarlo al login lo
    // obligaría a autenticarse de nuevo por un problema de conectividad.
    mockProfile(const FailureResult<AppUser?>(ConnectionFailure()));

    expect(await usecase.call(), PostAuthDestination.home);
  });

  test('un error del servidor tampoco lo expulsa al login', () async {
    mockProfile(const FailureResult<AppUser?>(ServerFailure()));

    expect(await usecase.call(), PostAuthDestination.home);
  });
}

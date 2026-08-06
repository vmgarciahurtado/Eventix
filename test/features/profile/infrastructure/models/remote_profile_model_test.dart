import 'package:eventix/features/profile/domain/entities/app_user.dart';
import 'package:eventix/features/profile/infrastructure/mappers/profile_mapper.dart';
import 'package:eventix/features/profile/infrastructure/models/remote_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parsea la fila completa de profiles', () {
    final RemoteProfileModel model = RemoteProfileModel.fromJson(
      <String, dynamic>{
        'id': 'user-1',
        'email': 'victor@correo.com',
        'first_name': 'Victor',
        'last_name': 'García',
        'onboarding_completed': true,
      },
    );

    expect(model.id, 'user-1');
    expect(model.email, 'victor@correo.com');
    expect(model.firstName, 'Victor');
    expect(model.lastName, 'García');
    expect(model.onboardingCompleted, isTrue);
  });

  test('un perfil recién creado sin nombres no rompe el parseo', () {
    final RemoteProfileModel model = RemoteProfileModel.fromJson(
      <String, dynamic>{'id': 'user-1'},
    );

    expect(model.email, '');
    expect(model.firstName, '');
    expect(model.lastName, '');
  });

  test('sin el flag, el onboarding se asume pendiente', () {
    // Con true por defecto, un perfil a medio crear se saltaría el onboarding.
    expect(
      RemoteProfileModel.fromJson(<String, dynamic>{'id': 'user-1'})
          .onboardingCompleted,
      isFalse,
    );
  });

  test('lanza si falta el id', () {
    expect(
      () => RemoteProfileModel.fromJson(<String, dynamic>{'email': 'a@b.com'}),
      throwsA(isA<TypeError>()),
    );
  });

  test('el mapper no expone el correo al dominio', () {
    final AppUser user = ProfileMapper.toEntity(
      const RemoteProfileModel(
        id: 'user-1',
        email: 'victor@correo.com',
        firstName: 'Victor',
        lastName: 'García',
        onboardingCompleted: false,
      ),
    );

    expect(user.id, 'user-1');
    expect(user.firstName, 'Victor');
    expect(user.onboardingCompleted, isFalse);
  });
}

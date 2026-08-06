import 'package:eventix/core/helpers/form_validators.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    final FormFieldValidator<String> validate = FormValidators.email(
      emptyMsg: 'vacío',
      invalidMsg: 'inválido',
    );

    test('exige un valor', () {
      expect(validate(null), 'vacío');
      expect(validate(''), 'vacío');
      expect(validate('   '), 'vacío');
    });

    test('acepta un correo bien formado ignorando espacios alrededor', () {
      expect(validate('victor@correo.com'), isNull);
      expect(validate('  victor@correo.com  '), isNull);
      expect(validate('a.b+c@sub.dominio.co'), isNull);
    });

    test('rechaza lo que no tiene arroba, dominio o punto', () {
      expect(validate('victor'), 'inválido');
      expect(validate('victor@correo'), 'inválido');
      expect(validate('@correo.com'), 'inválido');
      expect(validate('victor@.com'), 'inválido');
      expect(validate('a b@correo.com'), 'inválido');
    });
  });

  group('password', () {
    final FormFieldValidator<String> validate = FormValidators.password(
      emptyMsg: 'vacía',
      minMsg: 'corta',
    );

    test('exige un valor', () {
      expect(validate(null), 'vacía');
      expect(validate(''), 'vacía');
    });

    test('exige el mínimo de 6 que también valida Supabase', () {
      expect(validate('12345'), 'corta');
      expect(validate('123456'), isNull);
    });

    test('no recorta espacios: son caracteres válidos en una contraseña', () {
      expect(validate('      '), isNull);
    });
  });

  group('required', () {
    final FormFieldValidator<String> validate = FormValidators.required(
      message: 'obligatorio',
    );

    test('trata los espacios como vacío', () {
      expect(validate(null), 'obligatorio');
      expect(validate('   '), 'obligatorio');
      expect(validate('Victor'), isNull);
    });
  });

  group('confirmPassword', () {
    test('compara contra el valor actual del otro campo, no una copia', () {
      String original = 'primera';
      final FormFieldValidator<String> validate =
          FormValidators.confirmPassword(
            () => original,
            emptyMsg: 'confirma',
            mismatchMsg: 'no coinciden',
          );

      expect(validate('primera'), isNull);

      // Cambiar la contraseña invalida la confirmación que antes servía.
      original = 'segunda';
      expect(validate('primera'), 'no coinciden');
      expect(validate('segunda'), isNull);
    });

    test('exige un valor', () {
      final FormFieldValidator<String> validate =
          FormValidators.confirmPassword(
            () => '',
            emptyMsg: 'confirma',
            mismatchMsg: 'no coinciden',
          );
      expect(validate(null), 'confirma');
      expect(validate(''), 'confirma');
    });
  });
}

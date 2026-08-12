import 'package:eventix/features/app_config/domain/entities/localized_text.dart';

/// Identidad de marca configurable.
///
/// Los colores viajan como ARGB en vez de `Color` porque el dominio no depende
/// de Flutter. Ya vienen validados: el mapper solo deja pasar hex bien
/// formados y, si no, pone estos mismos valores por defecto.
class BrandConfig {
  const BrandConfig({
    required this.tagline,
    required this.primaryArgb,
    required this.secondaryArgb,
  });

  /// Mismos valores que `AppPalette.primary` y `AppPalette.secondary`, que es
  /// lo que se ve si el JSON no trae colores. Un test fija que no se separen.
  static const BrandConfig fallback = BrandConfig(
    tagline: LocalizedText(<String, String>{
      'es': 'Tu próxima fiesta empieza aquí',
      'en': 'Your next party starts here',
    }),
    primaryArgb: 0xFFF2F04B,
    secondaryArgb: 0xFFE64BC8,
  );

  final LocalizedText tagline;
  final int primaryArgb;
  final int secondaryArgb;
}

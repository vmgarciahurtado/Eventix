import 'package:eventix/features/app_config/domain/entities/localized_text.dart';
import 'package:eventix/features/app_config/domain/enums/app_icon.dart';

/// Una lámina del onboarding. Agregar o quitar láminas es editar esta lista en
/// el JSON: la pantalla no sabe cuántas hay.
class OnboardingSlideConfig {
  const OnboardingSlideConfig({
    required this.icon,
    required this.title,
    required this.body,
  });

  final AppIcon icon;
  final LocalizedText title;
  final LocalizedText body;
}

class OnboardingConfig {
  const OnboardingConfig({required this.slides});

  static const OnboardingConfig fallback = OnboardingConfig(
    slides: <OnboardingSlideConfig>[
      OnboardingSlideConfig(
        icon: AppIcon.explore,
        title: LocalizedText(<String, String>{
          'es': 'Descubre eventos',
          'en': 'Discover events',
        }),
        body: LocalizedText(<String, String>{
          'es': 'Explora conciertos, ferias y experiencias cerca de ti.',
          'en': 'Browse concerts, fairs and experiences near you.',
        }),
      ),
      OnboardingSlideConfig(
        icon: AppIcon.filter,
        title: LocalizedText(<String, String>{
          'es': 'Filtra a tu medida',
          'en': 'Filter your way',
        }),
        body: LocalizedText(<String, String>{
          'es': 'Encuentra eventos por categoría, fecha o ciudad.',
          'en': 'Find events by category, date or city.',
        }),
      ),
      OnboardingSlideConfig(
        icon: AppIcon.ticket,
        title: LocalizedText(<String, String>{
          'es': 'Reserva tus cupos',
          'en': 'Book your spots',
        }),
        body: LocalizedText(<String, String>{
          'es': 'Aparta tus entradas y revisa tus reservas cuando quieras.',
          'en': 'Grab your tickets and check your bookings anytime.',
        }),
      ),
    ],
  );

  /// Nunca vacía: una lista sin láminas dejaría el onboarding en blanco, así
  /// que el mapper cae a [fallback].
  final List<OnboardingSlideConfig> slides;
}

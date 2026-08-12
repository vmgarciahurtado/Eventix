import 'package:eventix/features/app_config/domain/entities/localized_text.dart';
import 'package:eventix/features/app_config/domain/enums/app_icon.dart';
import 'package:eventix/features/app_config/domain/enums/banner_target.dart';

/// Botón del banner. Sin etiqueta o con destino [BannerTarget.none] el banner
/// se pinta sin botón.
class BannerActionConfig {
  const BannerActionConfig({required this.label, required this.target});

  final LocalizedText label;
  final BannerTarget target;

  bool get isUsable =>
      target != BannerTarget.none && label.values.values.any(_hasText);

  static bool _hasText(String value) => value.trim().isNotEmpty;
}

/// Banner promocional de la pantalla de eventos.
class BannerConfig {
  const BannerConfig({
    required this.enabled,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  static const BannerConfig fallback = BannerConfig(
    enabled: false,
    icon: AppIcon.party,
    title: LocalizedText.empty,
    subtitle: LocalizedText.empty,
  );

  final bool enabled;
  final AppIcon icon;
  final LocalizedText title;
  final LocalizedText subtitle;
  final BannerActionConfig? action;
}

import 'package:eventix/core/helpers/hex_color.dart';
import 'package:eventix/core/helpers/json_map.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/entities/banner_config.dart';
import 'package:eventix/features/app_config/domain/entities/brand_config.dart';
import 'package:eventix/features/app_config/domain/entities/filters_config.dart';
import 'package:eventix/features/app_config/domain/entities/home_config.dart';
import 'package:eventix/features/app_config/domain/entities/localized_text.dart';
import 'package:eventix/features/app_config/domain/entities/onboarding_config.dart';
import 'package:eventix/features/app_config/domain/enums/app_icon.dart';
import 'package:eventix/features/app_config/domain/enums/banner_target.dart';
import 'package:eventix/features/app_config/domain/enums/home_block.dart';

/// Traduce el JSON a entidades. No hay modelo intermedio como en las features
/// que hablan con Supabase: el contrato es nuestro y aquí cada campo ya se lee
/// con su respaldo, así que un DTO solo repetiría la estructura.
///
/// La regla es que este mapper nunca lanza. Un archivo incompleto, con tipos
/// cambiados o con valores desconocidos produce una configuración válida.
abstract final class AppConfigMapper {
  static AppConfig toEntity(JsonMap json) => AppConfig(
    version: json.integer('version', fallback: AppConfig.fallback.version),
    brand: _brand(json.child('brand')),
    onboarding: _onboarding(json.child('onboarding')),
    home: _home(json.child('home')),
    filters: _filters(json.child('filters')),
  );

  static BrandConfig _brand(JsonMap json) {
    const BrandConfig base = BrandConfig.fallback;
    return BrandConfig(
      tagline: _text(json, 'tagline', base.tagline),
      primaryArgb: parseArgb(json.string('primaryColor')) ?? base.primaryArgb,
      secondaryArgb:
          parseArgb(json.string('secondaryColor')) ?? base.secondaryArgb,
    );
  }

  static OnboardingConfig _onboarding(JsonMap json) {
    final List<OnboardingSlideConfig> slides = <OnboardingSlideConfig>[
      for (final JsonMap slide in json.children('slides'))
        if (_text(slide, 'title', LocalizedText.empty) != LocalizedText.empty)
          OnboardingSlideConfig(
            icon: AppIcon.parse(slide.string('icon')),
            title: _text(slide, 'title', LocalizedText.empty),
            body: _text(slide, 'body', LocalizedText.empty),
          ),
    ];
    // Sin láminas legibles el onboarding quedaría en blanco.
    if (slides.isEmpty) return OnboardingConfig.fallback;
    return OnboardingConfig(
      slides: List<OnboardingSlideConfig>.unmodifiable(slides),
    );
  }

  static HomeConfig _home(JsonMap json) => HomeConfig(
    blocks: _blocks(json),
    banner: _banner(json.child('banner')),
    emptyState: _emptyState(json.child('emptyState')),
  );

  /// Respeta el orden del archivo, ignora los nombres desconocidos y descarta
  /// los repetidos. Si el resultado no incluye la lista de eventos la agrega:
  /// una pantalla de eventos sin eventos no es una configuración válida.
  static List<HomeBlock> _blocks(JsonMap json) {
    final List<HomeBlock> blocks = <HomeBlock>[];
    for (final String name in json.strings('blocks')) {
      final HomeBlock? block = HomeBlock.tryParse(name);
      if (block != null && !blocks.contains(block)) blocks.add(block);
    }
    if (blocks.isEmpty) return HomeBlock.fallback;
    if (!blocks.contains(HomeBlock.mandatory)) blocks.add(HomeBlock.mandatory);
    return List<HomeBlock>.unmodifiable(blocks);
  }

  static BannerConfig _banner(JsonMap json) {
    if (json.isEmpty) return BannerConfig.fallback;
    return BannerConfig(
      enabled: json.boolean('enabled', fallback: false),
      icon: AppIcon.parse(json.string('icon'), fallback: AppIcon.party),
      title: _text(json, 'title', LocalizedText.empty),
      subtitle: _text(json, 'subtitle', LocalizedText.empty),
      action: _action(json.child('action')),
    );
  }

  /// Un botón sin etiqueta o sin destino conocido no se pinta, en vez de
  /// dejar un botón que no lleva a ninguna parte.
  static BannerActionConfig? _action(JsonMap json) {
    if (json.isEmpty) return null;
    final BannerActionConfig action = BannerActionConfig(
      label: _text(json, 'label', LocalizedText.empty),
      target: BannerTarget.parse(json.string('target')),
    );
    return action.isUsable ? action : null;
  }

  static EmptyStateConfig _emptyState(JsonMap json) {
    const EmptyStateConfig base = EmptyStateConfig.fallback;
    return EmptyStateConfig(
      title: _text(json, 'title', base.title),
      message: _text(json, 'message', base.message),
    );
  }

  static FiltersConfig _filters(JsonMap json) => FiltersConfig(
    cityEnabled: json.boolean('cityEnabled', fallback: true),
    dateEnabled: json.boolean('dateEnabled', fallback: true),
    pinnedCategories: List<String>.unmodifiable(
      json.strings('pinnedCategories'),
    ),
    hiddenCategories: List<String>.unmodifiable(
      json.strings('hiddenCategories'),
    ),
  );

  /// Acepta el mapa por idioma y, como atajo, un texto plano, que se toma como
  /// el idioma base del archivo.
  static LocalizedText _text(
    JsonMap json,
    String key,
    LocalizedText fallback,
  ) {
    final Map<String, String> values = json.stringMap(key);
    if (values.isNotEmpty) return LocalizedText(values);
    final String plain = json.string(key);
    if (plain.trim().isNotEmpty) {
      return LocalizedText(<String, String>{
        LocalizedText.fallbackLanguage: plain,
      });
    }
    return fallback;
  }
}

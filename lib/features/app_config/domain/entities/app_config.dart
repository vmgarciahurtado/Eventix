import 'package:eventix/features/app_config/domain/entities/brand_config.dart';
import 'package:eventix/features/app_config/domain/entities/filters_config.dart';
import 'package:eventix/features/app_config/domain/entities/home_config.dart';
import 'package:eventix/features/app_config/domain/entities/onboarding_config.dart';

/// Configuración de la app que vive en `assets/config/app_config.json`.
///
/// El JSON decide contenido y presentación, no comportamiento crítico: nada de
/// lo que hay aquí puede dejar la app sin arrancar. Si el archivo falta o está
/// mal, se usa [fallback], que reproduce lo que la app traía cableado.
class AppConfig {
  const AppConfig({
    required this.version,
    required this.brand,
    required this.onboarding,
    required this.home,
    required this.filters,
  });

  static const AppConfig fallback = AppConfig(
    version: 1,
    brand: BrandConfig.fallback,
    onboarding: OnboardingConfig.fallback,
    home: HomeConfig.fallback,
    filters: FiltersConfig.fallback,
  );

  /// Versión del contrato. Sirve para detectar un archivo de otra época.
  final int version;

  final BrandConfig brand;
  final OnboardingConfig onboarding;
  final HomeConfig home;
  final FiltersConfig filters;
}

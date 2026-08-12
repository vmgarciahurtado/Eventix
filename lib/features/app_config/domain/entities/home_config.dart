import 'package:eventix/features/app_config/domain/entities/banner_config.dart';
import 'package:eventix/features/app_config/domain/entities/localized_text.dart';
import 'package:eventix/features/app_config/domain/enums/home_block.dart';

/// Texto del estado vacío de una lista.
class EmptyStateConfig {
  const EmptyStateConfig({required this.title, required this.message});

  static const EmptyStateConfig fallback = EmptyStateConfig(
    title: LocalizedText(<String, String>{
      'es': 'Sin eventos',
      'en': 'No events',
    }),
    message: LocalizedText(<String, String>{
      'es': 'No encontramos eventos con estos filtros.',
      'en': 'We found no events matching these filters.',
    }),
  );

  final LocalizedText title;
  final LocalizedText message;
}

class HomeConfig {
  const HomeConfig({
    required this.blocks,
    required this.banner,
    required this.emptyState,
  });

  static const HomeConfig fallback = HomeConfig(
    blocks: HomeBlock.fallback,
    banner: BannerConfig.fallback,
    emptyState: EmptyStateConfig.fallback,
  );

  /// Orden en el que se pintan los bloques. Siempre contiene
  /// [HomeBlock.mandatory].
  final List<HomeBlock> blocks;
  final BannerConfig banner;
  final EmptyStateConfig emptyState;
}

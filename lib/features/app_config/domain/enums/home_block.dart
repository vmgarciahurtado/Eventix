/// Bloques que componen la pantalla de eventos. El JSON decide cuáles se
/// pintan y en qué orden.
enum HomeBlock {
  banner,
  filters,
  events;

  /// Sin este bloque la pantalla no tendría contenido, así que el mapper lo
  /// reincorpora aunque el JSON lo omita.
  static const HomeBlock mandatory = HomeBlock.events;

  static const List<HomeBlock> fallback = <HomeBlock>[
    HomeBlock.banner,
    HomeBlock.filters,
    HomeBlock.events,
  ];

  static HomeBlock? tryParse(String? name) {
    for (final HomeBlock block in HomeBlock.values) {
      if (block.name == name) return block;
    }
    return null;
  }
}

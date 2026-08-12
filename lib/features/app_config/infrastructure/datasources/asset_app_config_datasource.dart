import 'dart:convert';

import 'package:eventix/core/helpers/json_map.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/app_config_datasource.dart';
import 'package:flutter/services.dart';

/// Lee la configuración del bundle de assets.
class AssetAppConfigDatasource implements AppConfigDatasource {
  const AssetAppConfigDatasource(this._bundle);

  static const String assetPath = 'assets/config/app_config.json';

  final AssetBundle _bundle;

  /// Un archivo que no sea un objeto JSON se trata como vacío: el mapper lo
  /// resuelve con los valores por defecto. Que el asset no exista sí es un
  /// error, y lo propaga el bundle.
  @override
  Future<JsonMap> fetch() async {
    final String raw = await _bundle.loadString(assetPath);
    return JsonMap.of(jsonDecode(raw));
  }

  @override
  Future<void> invalidate() async => _bundle.evict(assetPath);
}

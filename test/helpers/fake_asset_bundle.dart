import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// `AssetBundle` con el contenido en memoria.
///
/// Hereda de `CachingAssetBundle` para que la caché se comporte como la real:
/// [loads] cuenta las lecturas de verdad, así que sirve para comprobar que
/// `evict` funciona.
class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.contents);

  final Map<String, String> contents;

  int loads = 0;

  @override
  Future<ByteData> load(String key) async {
    final String? value = contents[key];
    if (value == null) throw FlutterError('Asset ausente en la prueba: $key');
    loads++;
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

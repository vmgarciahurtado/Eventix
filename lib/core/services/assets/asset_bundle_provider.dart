import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bundle de assets de la app. Se expone por DI para poder darle uno falso a
/// las pruebas sin tocar `rootBundle`.
final Provider<AssetBundle> assetBundleProvider = Provider<AssetBundle>(
  (Ref ref) => rootBundle,
);

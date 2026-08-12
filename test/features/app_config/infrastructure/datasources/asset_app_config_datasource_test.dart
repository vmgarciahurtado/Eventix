import 'package:eventix/core/helpers/json_map.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/asset_app_config_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_asset_bundle.dart';

void main() {
  const String path = AssetAppConfigDatasource.assetPath;

  AssetAppConfigDatasource datasourceWith(
    FakeAssetBundle bundle,
  ) => AssetAppConfigDatasource(bundle);

  test('decodifica el asset', () async {
    final AssetAppConfigDatasource datasource = datasourceWith(
      FakeAssetBundle(<String, String>{path: '{"version": 7}'}),
    );

    final JsonMap json = await datasource.fetch();

    expect(json.integer('version', fallback: 0), 7);
  });

  test('un archivo que no es un objeto se lee vacío', () async {
    final AssetAppConfigDatasource datasource = datasourceWith(
      FakeAssetBundle(<String, String>{path: '"solo un texto"'}),
    );

    expect((await datasource.fetch()).isEmpty, isTrue);
  });

  test('un JSON roto propaga el error en vez de disimularlo', () async {
    final AssetAppConfigDatasource datasource = datasourceWith(
      FakeAssetBundle(<String, String>{path: '{"version": }'}),
    );

    await expectLater(datasource.fetch(), throwsFormatException);
  });

  test('un asset ausente propaga el error del bundle', () async {
    final AssetAppConfigDatasource datasource = datasourceWith(
      FakeAssetBundle(<String, String>{}),
    );

    await expectLater(datasource.fetch(), throwsA(isA<FlutterError>()));
  });

  group('caché', () {
    test('la segunda lectura no vuelve al archivo', () async {
      final FakeAssetBundle bundle = FakeAssetBundle(<String, String>{
        path: '{"version": 1}',
      });
      final AssetAppConfigDatasource datasource = datasourceWith(bundle);

      await datasource.fetch();
      await datasource.fetch();

      expect(bundle.loads, 1);
    });

    test('invalidar obliga a releer, que es lo que permite recargar', () async {
      final FakeAssetBundle bundle = FakeAssetBundle(<String, String>{
        path: '{"version": 1}',
      });
      final AssetAppConfigDatasource datasource = datasourceWith(bundle);

      await datasource.fetch();
      await datasource.invalidate();
      bundle.contents[path] = '{"version": 2}';
      final JsonMap json = await datasource.fetch();

      expect(bundle.loads, 2);
      expect(json.integer('version', fallback: 0), 2);
    });
  });
}

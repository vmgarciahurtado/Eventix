#!/bin/bash
echo "🧪 Ejecutando pruebas con cobertura..."
flutter test --coverage

echo ""
echo "🧹 Filtrando archivos generados..."
lcov --remove coverage/lcov.info \
  '**/*.g.dart' \
  '**/*.gr.dart' \
  '**/*.config.dart' \
  '**/generated/**' \
  '**/.dart_tool/**' \
  -o coverage/lcov_filtered.info

echo ""
echo "📊 Generando reporte HTML..."
genhtml coverage/lcov_filtered.info -o coverage/html

echo ""
echo "✅ Reporte generado en coverage/html/index.html"

# Abrir según el SO
if [[ "$OSTYPE" == "darwin"* ]]; then
  open coverage/html/index.html
else
  xdg-open coverage/html/index.html
fi
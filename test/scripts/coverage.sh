#!/usr/bin/env bash
# Cobertura de la app: corre las pruebas, descarta lo generado y falla si el
# porcentaje baja del mínimo.
#
#   ./test/scripts/coverage.sh          # reporte en consola
#   ./test/scripts/coverage.sh --html   # además abre el reporte navegable
#
# Requiere lcov (`brew install lcov` en macOS, `apt install lcov` en Linux).
set -euo pipefail

MIN=80
cd "$(dirname "$0")/../.."

echo "==> flutter test --coverage"
flutter test --coverage

echo "==> descartando código generado"
lcov --remove coverage/lcov.info \
  'lib/core/l10n/*' \
  -o coverage/lcov.cleaned.info \
  --ignore-errors unused >/dev/null

lcov --list coverage/lcov.cleaned.info

PCT=$(lcov --summary coverage/lcov.cleaned.info 2>&1 \
  | grep -m1 'lines' \
  | sed -E 's/.*: ([0-9.]+)%.*/\1/')

if [[ "${1:-}" == "--html" ]]; then
  genhtml coverage/lcov.cleaned.info -o coverage/html --quiet
  echo "==> reporte en coverage/html/index.html"
  if command -v open >/dev/null; then
    open coverage/html/index.html
  elif command -v xdg-open >/dev/null; then
    xdg-open coverage/html/index.html
  fi
fi

echo "==> cobertura de líneas: ${PCT}% (mínimo ${MIN}%)"
awk -v pct="$PCT" -v min="$MIN" 'BEGIN { exit (pct + 0 >= min + 0) ? 0 : 1 }' || {
  echo "FALLA: la cobertura quedó por debajo del mínimo exigido." >&2
  exit 1
}
echo "OK"

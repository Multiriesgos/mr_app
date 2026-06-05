#!/usr/bin/env bash
# Instala los Git hooks del proyecto.
# Correr una vez al clonar: bash scripts/install-hooks.sh

set -e

HOOKS_DIR="$(git rev-parse --git-dir)/hooks"

cat > "$HOOKS_DIR/pre-commit" << 'HOOK'
#!/usr/bin/env bash
# Pre-commit: format + analyze + test
set -e

echo "▶ dart format --set-exit-if-changed ."
dart format --set-exit-if-changed . || {
  echo "✗ Hay archivos sin formatear. Corre: dart format ."
  exit 1
}

echo "▶ flutter analyze --fatal-warnings"
flutter analyze --fatal-warnings || {
  echo "✗ El análisis falló. Corrige los warnings antes de commitear."
  exit 1
}

echo "▶ flutter test"
flutter test || {
  echo "✗ Tests fallidos. Corrígelos antes de commitear."
  exit 1
}

echo "✓ Pre-commit OK"
HOOK

chmod +x "$HOOKS_DIR/pre-commit"
echo "✓ Hook pre-commit instalado en $HOOKS_DIR/pre-commit"
echo "  Se ejecutará automáticamente en cada git commit."

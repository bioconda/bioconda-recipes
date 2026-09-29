#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$PREFIX/bin" "$PREFIX/share/gatk4-lite"
cp "gatk-package-${PKG_VERSION}-local.jar" "$PREFIX/share/gatk4-lite/gatk.jar"
unzip -p "gatk-package-${PKG_VERSION}-local.jar" META-INF/LICENSE > "$SRC_DIR/LICENSE-gatk.txt"

cp "$RECIPE_DIR/gatk-lite" "$PREFIX/bin/gatk"
chmod +x "$PREFIX/bin/gatk"

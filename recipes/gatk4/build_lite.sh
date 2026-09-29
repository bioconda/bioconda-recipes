#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$PREFIX/bin" "$PREFIX/share/gatk4-lite"
cp "gatk-package-${PKG_VERSION}-local.jar" "$PREFIX/share/gatk4-lite/gatk.jar"
unzip -p "gatk-package-${PKG_VERSION}-local.jar" META-INF/LICENSE > "$SRC_DIR/LICENSE-gatk.txt"

jlink --add-modules \
    java.base,java.logging,java.xml,java.management,java.naming,java.sql,java.desktop,jdk.unsupported,jdk.crypto.ec,java.security.jgss,java.instrument,jdk.zipfs,java.net.http \
    --strip-debug --no-header-files --no-man-pages --compress=2 \
    --output "$PREFIX/share/gatk4-lite/runtime"

cp "$RECIPE_DIR/gatk-lite" "$PREFIX/bin/gatk"
chmod +x "$PREFIX/bin/gatk"

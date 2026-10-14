#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$PREFIX/bin" "$PREFIX/lib" "$PREFIX/share/gatk4-lite"
cp "gatk-package-${PKG_VERSION}-local.jar" "$PREFIX/share/gatk4-lite/gatk.jar"
unzip -p "gatk-package-${PKG_VERSION}-local.jar" META-INF/LICENSE > "$SRC_DIR/LICENSE-gatk.txt"

jlink --add-modules \
    java.base,java.logging,java.xml,java.management,java.naming,java.sql,java.desktop,jdk.unsupported,jdk.crypto.ec,java.security.jgss,jdk.security.auth,java.instrument,jdk.zipfs,java.net.http \
    --strip-debug --no-header-files --no-man-pages --compress=2 \
    --output "$PREFIX/lib/gatk4-lite-jvm"
cp "$PREFIX/lib/gatk4-lite-jvm/legal/java.base/LICENSE" "$SRC_DIR/LICENSE-openjdk.txt"
cp "$PREFIX/lib/gatk4-lite-jvm/legal/java.base/ASSEMBLY_EXCEPTION" "$SRC_DIR/ASSEMBLY_EXCEPTION-openjdk.txt"
cp "$PREFIX/lib/gatk4-lite-jvm/legal/java.base/ADDITIONAL_LICENSE_INFO" "$SRC_DIR/ADDITIONAL_LICENSE_INFO-openjdk.txt"

cp "$RECIPE_DIR/gatk-lite" "$PREFIX/bin/gatk"
chmod +x "$PREFIX/bin/gatk"

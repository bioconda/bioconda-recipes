#!/usr/bin/env bash
set -euo pipefail

echo "Installing TEexpo..."

############################################
# Create directories
############################################

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/share/teexpo/scripts"

############################################
# Copy scripts
############################################

cp -r "$SRC_DIR/scripts/"* "$PREFIX/share/teexpo/scripts/"

############################################
# Make scripts executable
############################################

find "$PREFIX/share/teexpo/scripts" -type f -name "*.sh" -exec chmod +x {} \;

############################################
# Install main launcher
############################################

chmod +x "$SRC_DIR/bin/teexpo"
cp "$SRC_DIR/bin/teexpo" "$PREFIX/bin/teexpo"
chmod +x "$PREFIX/bin/teexpo"

############################################
# Fix Windows line endings
############################################

sed -i 's/\r$//' "$PREFIX/bin/teexpo"
find "$PREFIX/share/teexpo/scripts" -type f -name "*.sh" -exec sed -i 's/\r$//' {} \;

echo "TEexpo installation complete."
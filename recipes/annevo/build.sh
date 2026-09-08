#!/bin/bash
set -euo pipefail

INSTALL_DIR="$PREFIX/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "$INSTALL_DIR"

cp -r annotation.py prediction.py decoding.py model datamodule src saved_model "$INSTALL_DIR/"

mkdir -p "$PREFIX/bin"

for script in annotation prediction decoding; do
  sed -i "1i #!$PREFIX/bin/python" "$INSTALL_DIR/${script}.py"
  chmod +x "$INSTALL_DIR/${script}.py"
  ln -s "../share/${PKG_NAME}-${PKG_VERSION}/${script}.py" "$PREFIX/bin/${script}.py"
done
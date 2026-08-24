#!/bin/bash
set -euo pipefail

unzip -q "$SRC_DIR/$PKG_VERSION" -d "$SRC_DIR"

tool_root="$PREFIX/lib/dotnet/tools/PSMBasedQuantificationTIMs"
mkdir -p "$PREFIX/bin" "$tool_root"
cp -R "$SRC_DIR/tools/net8.0/any/." "$tool_root/"
cp "$RECIPE_DIR/proteomiqon-psmbasedquantificationtims.sh" \
    "$PREFIX/bin/proteomiqon-psmbasedquantificationtims"
chmod +x "$PREFIX/bin/proteomiqon-psmbasedquantificationtims"

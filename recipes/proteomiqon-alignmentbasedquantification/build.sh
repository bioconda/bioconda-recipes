#!/bin/bash
set -euo pipefail
unzip -q "$SRC_DIR/$PKG_VERSION" -d "$SRC_DIR"
PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
tool_root="$PREFIX/lib/dotnet/tools/AlignmentBasedQuantification"

mkdir -p "$PREFIX/bin" "$tool_root"
cp -R "$SRC_DIR/tools/net10.0/any/." "$tool_root/"
cp "$RECIPE_DIR/proteomiqon-alignmentbasedquantification.sh" "$PREFIX/bin/proteomiqon-alignmentbasedquantification"
chmod +x "$PREFIX/bin/proteomiqon-alignmentbasedquantification"

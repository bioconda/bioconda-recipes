#!/bin/bash
unzip $SRC_DIR/$PKG_VERSION
PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
DOTNET_ROOT="${PREFIX}/lib/dotnet"
TOOL_ROOT=$DOTNET_ROOT/tools/PSMStatistics

mkdir -p $PREFIX/bin $TOOL_ROOT
cp -r $SRC_DIR/tools/net5.0/any/* $TOOL_ROOT
cp "$RECIPE_DIR/proteomiqon-psmstatistics.sh" "$PREFIX/bin/proteomiqon-psmstatistics"
chmod +x "$PREFIX/bin/proteomiqon-psmstatistics"

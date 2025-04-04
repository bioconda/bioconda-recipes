#!/bin/bash
PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
DOTNET_ROOT="${PREFIX}/lib/dotnet"
FLASHLFQ_ROOT=$DOTNET_ROOT/tools/flashlfq

mkdir -p $PREFIX/bin $FLASHLFQ_ROOT
cp -r $SRC_DIR/* $FLASHLFQ_ROOT
cp "$RECIPE_DIR/FlashLFQ.sh" "$PREFIX/bin/FlashLFQ"
chmod +x "$PREFIX/bin/FlashLFQ"


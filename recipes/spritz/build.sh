#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
DOTNET_ROOT="${PREFIX}/lib/dotnet"
SPRITZ_ROOT=$DOTNET_ROOT/tools/spritz

mkdir -p $PREFIX/bin $SPRITZ_ROOT
cp -r $SRC_DIR/* $SPRITZ_ROOT

cp $RECIPE_DIR/spritz $PREFIX/bin/spritz
chmod +x $PREFIX/bin/spritz


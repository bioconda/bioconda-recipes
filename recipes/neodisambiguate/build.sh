#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
cp $RECIPE_DIR/neodisambiguate ${PREFIX}/bin/neodisambiguate
chmod +x ${PREFIX}/bin/neodisambiguate

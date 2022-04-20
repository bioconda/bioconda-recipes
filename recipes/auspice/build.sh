#!/bin/sh
set -euo pipefail

mkdir -p $PREFIX/lib/auspice
pushd $PREFIX/lib/auspice
    yarn add --non-interactive --ignore-engines $SRC_DIR
popd

mkdir -p $PREFIX/bin
pushd $PREFIX/bin
    ln -s ../lib/auspice/node_modules/.bin/auspice .
popd

# For the license_file field in meta.yaml
cp $PREFIX/lib/auspice/node_modules/auspice/LICENSE.txt $SRC_DIR

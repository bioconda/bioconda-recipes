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
if [ -f $PREFIX/lib/auspice/node_modules/watchpack-chokidar2/node_modules/fsevents/build/node_gyp_bins/python3 ] ; then
    unlink $PREFIX/lib/auspice/node_modules/watchpack-chokidar2/node_modules/fsevents/build/node_gyp_bins/python3
fi

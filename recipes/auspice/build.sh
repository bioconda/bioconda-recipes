#!/bin/sh
set -xeuo

AUSPICE_LIB_DIR="$PREFIX"/lib/auspice
mkdir -p "$AUSPICE_LIB_DIR"
cd "$AUSPICE_LIB_DIR"
yarn add --non-interactive --ignore-engines "$SRC_DIR"
yarn cache clean --all # Remove 250 MB source cache added

BIN_DIR="$PREFIX"/bin
mkdir -p "$BIN_DIR"
cd "$BIN_DIR"
ln -s ../lib/auspice/node_modules/.bin/auspice .

# For the license_file field in meta.yaml
cp "$AUSPICE_LIB_DIR"/node_modules/auspice/LICENSE.txt "$SRC_DIR"

NODE_GYP_PYTHON="$AUSPICE_LIB_DIR"/node_modules/watchpack-chokidar2/node_modules/fsevents/build/node_gyp_bins/python3
if [ -f "$NODE_GYP_PYTHON" ]; then
    unlink "$NODE_GYP_PYTHON"
fi

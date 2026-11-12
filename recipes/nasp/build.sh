#!/bin/bash
set -euo pipefail

export CGO_ENABLED=0
pushd nasp/nasptool
go build -mod=readonly -trimpath -o ../nasptool_linux_64
popd

"$PYTHON" -m pip install --no-deps --no-build-isolation --ignore-installed --no-cache-dir -vvv .

# Find the installed JARs before linking; refresh on activation after tool updates.
mkdir -p "$PREFIX/etc/conda/activate.d"
cp "$RECIPE_DIR/nasp-jars.sh" "$PREFIX/etc/conda/activate.d/nasp-jars.sh"
CONDA_PREFIX="$PREFIX" bash "$RECIPE_DIR/nasp-jars.sh"

# NASP expects an underscore; Bioconda's SNAP executable uses a hyphen.
mkdir -p "$PREFIX/bin"
ln -s snap-aligner "$PREFIX/bin/snap_aligner"

#!/usr/bin/env bash
set -euxo pipefail

cd "$SRC_DIR"

make clean || true

echo "PREFIX is $PREFIX"
echo "Listing headers under \$PREFIX/include:"
ls -R "$PREFIX/include" || true

make USE_CONDA=1 PREFIX="$PREFIX" -j${CPU_COUNT}

mkdir -p "$PREFIX/bin"
cp build/svarp "$PREFIX/bin/svarp"
chmod +x "$PREFIX/bin/svarp"


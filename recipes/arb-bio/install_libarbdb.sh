#!/bin/bash

mkdir -p "$PREFIX/lib/arb/lib"
for fn in libARBDB libCORE arb_tcp.dat; do
    mv install/lib/arb/lib/$fn* "$PREFIX/lib/arb/lib"
done

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "$RECIPE_DIR/activate.sh" "$PREFIX/etc/conda/activate.d/arb_home.sh"
cp "$RECIPE_DIR/deactivate.sh" "$PREFIX/etc/conda/deactivate.d/arb_home.sh"

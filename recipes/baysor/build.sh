#!/bin/bash

export JULIA_DEPOT_PATH="$PREFIX/share/julia"
mkdir -p "$JULIA_DEPOT_PATH"

julia \
    --startup-file=no \
    --history-file=no \
    --threads 1 \
    -e 'using Pkg; Pkg.develop(path="."); Pkg.build("Baysor")'

mkdir -p "$PREFIX/bin"
mv "$PREFIX/share/julia/bin/baysor" "$PREFIX/bin/baysor"

chmod +x "$PREFIX/bin/baysor"

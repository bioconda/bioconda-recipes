#!/bin/bash

export JULIA_DEPOT_PATH="$PREFIX/share/julia"
mkdir -p "$JULIA_DEPOT_PATH"

julia -e 'using Pkg; Pkg.add(PackageSpec(url="https://github.com/kharchenkolab/Baysor.git")); Pkg.build()'

mkdir -p "$PREFIX/bin"
mv "$PREFIX/share/julia/bin/baysor" "$PREFIX/bin/baysor"

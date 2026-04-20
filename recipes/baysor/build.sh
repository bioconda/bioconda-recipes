#!/bin/bash

export JULIA_DEPOT_PATH="$PREFIX/share/julia"
mkdir -p "$JULIA_DEPOT_PATH"

# PackageCompiler.jl autodetects only `gcc`/`clang` by name; point it at conda's CC.
export JULIA_CC="$CC"

# Ghostscript_jll's libgs.so dlopens libz.so.1 and the CentOS 7 /lib64 one is too old
# (missing ZLIB_1.2.9). Prefer conda's newer zlib.
export LD_LIBRARY_PATH="$PREFIX/lib:$BUILD_PREFIX/lib:$LD_LIBRARY_PATH"

julia -e 'using Pkg; Pkg.add("HDF5"); Pkg.develop(path="."); Pkg.build("Baysor")'

mkdir -p "$PREFIX/bin"
mv "$PREFIX/share/julia/bin/baysor" "$PREFIX/bin/baysor"

chmod +x "$PREFIX/bin/baysor"

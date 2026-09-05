#!/usr/bin/env bash

set -euo pipefail

export JULIA_CPU_TARGET=generic
export JULIA_CC="${CC}"

julia --project="${SRC_DIR}/build" -e 'using Pkg; Pkg.instantiate()'
sed -i.bak 's/cp(match, destpath)$/cp(match, destpath; follow_symlinks=true)/' \
    "${BUILD_PREFIX}"/share/julia/packages/PackageCompiler/*/src/PackageCompiler.jl

julia --project="${SRC_DIR}/build" "${SRC_DIR}/build/build_app.jl"

install -d "${PREFIX}/libexec" "${PREFIX}/bin"
cp -R "${SRC_DIR}/build/compiled" "${PREFIX}/libexec/patchwork"
ln -s "../libexec/patchwork/bin/patchwork" "${PREFIX}/bin/patchwork"

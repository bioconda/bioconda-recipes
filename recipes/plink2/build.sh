#!/bin/bash
set -xe

cd 2.0/build_dynamic

# The Makefile sets its own CFLAGS/CXXFLAGS and ignores LDFLAGS, so point the
# compilers at the host prefix through the environment instead.
export CPATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

# Link against conda's zstd rather than the bundled copy.
args=(CC="${CC}" CXX="${CXX}" STATIC_ZSTD=)
if [[ "$(uname)" != "Darwin" ]]; then
  # OpenBLAS ships LAPACK and LAPACKE, so a single -lopenblas is enough.
  args+=(BLASFLAGS="-L${PREFIX}/lib -lopenblas")
fi

make -j"${CPU_COUNT}" "${args[@]}"

mkdir -p "${PREFIX}/bin"
install -m 755 plink2 pgen_compress "${PREFIX}/bin/"

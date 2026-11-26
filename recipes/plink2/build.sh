#!/bin/bash
set -xe

cd 2.0/build_dynamic

export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

# Link against conda's zstd rather than the bundled copy.
# MAC_NEW_LAPACK unset since macOS build target is still 11.0.
args=(CC="${CC}" CXX="${CXX}" STATIC_ZSTD= MAC_NEW_LAPACK=)
if [[ "$(uname)" != "Darwin" ]]; then
  # OpenBLAS ships LAPACK and LAPACKE, so a single -lopenblas is enough.
  args+=(BLASLIBS="-lopenblas")
fi

make -j"${CPU_COUNT}" "${args[@]}"

mkdir -p "${PREFIX}/bin"
install -m 755 plink2 pgen_compress "${PREFIX}/bin/"

cd ../utils/ldsc
make -j"${CPU_COUNT}" "${args[@]}"
install -m 755 ldsc "${PREFIX}/bin/"

cd ../mtag
make -j"${CPU_COUNT}" "${args[@]}"
install -m 755 mtag "${PREFIX}/bin/"

cd ../vcf_subset
make -j"${CPU_COUNT}" "${args[@]}"
install -m 755 vcf_subset "${PREFIX}/bin/"

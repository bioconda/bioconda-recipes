#!/bin/bash
set -ex 

case $(uname -m) in
	aarch64|arm64) sed -i.bak 's|-mavx2||' include.mk && sed -i.bak 's|-D__AVX2__||' include.mk && rm -rf *.bak
  ;;
esac

cd submodules/abPOA
make EXTRA_FLAGS="-O3 -Wall -Wno-unused-function -Wno-misleading-indentation -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES -I${PREFIX}/include -L${PREFIX}/lib" -j"${CPU_COUNT}"
make EXTRA_FLAGS="-O3 -Wall -Wno-unused-function -Wno-misleading-indentation -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES -I${PREFIX}/include -L${PREFIX}/lib" src/abpoa_align_simd.o -j"${CPU_COUNT}"
make EXTRA_FLAGS="-O3 -Wall -Wno-unused-function -Wno-misleading-indentation -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES -I${PREFIX}/include -L${PREFIX}/lib" avx2=1 -j"${CPU_COUNT}"
cd ../../

cd submodules/FASTGA
make CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib" CC="${CC}" -j"${CPU_COUNT}"
cd ../../

cd submodules/cPecan/externalTools/lastz-distrib-1.03.54/src
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include/libxml2"
make CC="${CC}" -j"${CPU_COUNT}"
cd ../../../../../

sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
rm -rf *.bak
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv

make
mv bin/* ${PREFIX}/bin

# cactus-gfa-tools is required but doesn't have tags. They just use exact commits in their scripts
git clone https://github.com/ComparativeGenomicsToolkit/cactus-gfa-tools.git
cd cactus-gfa-tools
git checkout 1121e370880ee187ba2963f0e46e632e0e762cc5

make -j"${CPU_COUNT}"

install -v -m 755 mzgaf2paf pafcoverage rgfa-split paf2lastz pafmask gaf2paf gaf2unstable gaffilter rgfa2paf paf2stable "${PREFIX}/bin"

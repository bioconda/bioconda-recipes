#!/bin/bash
set -ex 
cd submodules/abPOA
make EXTRA_FLAGS="-Wall -Wno-unused-function -Wno-misleading-indentation -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES -I${PREFIX}/include -L${PREFIX}/lib"
make EXTRA_FLAGS="-Wall -Wno-unused-function -Wno-misleading-indentation -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES -I${PREFIX}/include -L${PREFIX}/lib" src/abpoa_align_simd.o
make EXTRA_FLAGS="-Wall -Wno-unused-function -Wno-misleading-indentation -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES -I${PREFIX}/include -L${PREFIX}/lib" avx2=1
cd ../../

cd submodules/FASTGA
make CFLAGS="${CFLAGS} -L${PREFIX}/lib" CC="${CC}"
cd ../../

cd submodules/cPecan/externalTools/lastz-distrib-1.03.54/src
export CFLAGS="${CFLAGS} -I${PREFIX}/include/libxml2"
make CC="${CC}"
cd ../../../../../

${PYTHON} -m pip install .
make
mv bin/* ${PREFIX}/bin

# cactus-gfa-tools is required but doesn't have tags. They just use exact commits in their scripts
git clone https://github.com/ComparativeGenomicsToolkit/cactus-gfa-tools.git
cd cactus-gfa-tools
git checkout 1121e370880ee187ba2963f0e46e632e0e762cc5
make
for exe in mzgaf2paf pafcoverage rgfa-split paf2lastz pafmask gaf2paf gaf2unstable gaffilter ; do
    mv ${exe} ${PREFIX}/bin/
done
cd ..

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

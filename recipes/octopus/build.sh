#!/bin/bash

set -xeu -o pipefail

export CPATH=${PREFIX}/include
export CMAKE_LDFLAGS="-L${PREFIX}/lib"
export LIBRARY_PATH=${PREFIX}/lib

# There are deprecated functions uses which causes failures
for f in src/CMakeLists.txt lib/ranger/CMakeLists.txt lib/tandem/CMakeLists.txt lib/date/CMakeLists.txt; do
    sed -i.bak "s/-Werror //g" $f
done

case $(uname -m) in
    x86_64)
        CPU_ARCH="--architecture haswell"
        ;;
    *)
        CPU_ARCH=""
        ;;
esac

scripts/install.py \
    -c ${CC_FOR_BUILD} \
    -cxx ${CXX_FOR_BUILD} \
    --prefix ${PREFIX}/bin \
    --gmp ${PREFIX} \
    --boost ${PREFIX} \
    --htslib ${PREFIX} \
    ${CPU_ARCH} \
    --threads ${CPU_COUNT} \
    --verbose

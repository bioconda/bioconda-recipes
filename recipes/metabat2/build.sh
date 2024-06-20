#!/bin/bash

set -xe 

#sed -i.bak "s/set(Boost_USE_STATIC_LIBS   ON)/set(Boost_USE_STATIC_LIBS   OFF)/g" src/CMakeLists.txt
mkdir build
cd build

export CXXFLAGS=-ldeflate
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_ROOT=$PREFIX

if [ "$(uname -m)" == "aarch64" ]; then
    # fetch the htslib dependency
    make htslib/fast
    pushd ./contrib/htslib-prefix/src/htslib
      patch -p1 < ${RECIPE_DIR}/arm_hwcap.patch
    popd
fi

# Fix the version
make check_git_repository
sed -i.bak 's/GIT-NOTFOUND/'$PKG_VERSION' (Bioconda)/'  ../metabat_version.h

# Build & install
make VERBOSE=1 -j ${CPU_COUNT}
make install

#!/bin/bash
set -xe 

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -ldeflate"

# Fix the version
# make check_git_repository
sed -i.bak 's/GIT-NOTFOUND/'$PKG_VERSION' (Bioconda)/' version.h

sed -i.bak 's|VERSION 3.5.1|VERSION 3.5|' CMakeLists.txt
sed -i.bak 's|17|14|' CMakeLists.txt
rm -rf *.bak

if [[ `uname` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release -DBOOST_ROOT="${PREFIX}" \
  -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  "${CONFIG_ARGS}"

# Build & install
cmake --build build --clean-first --target install -j "${CPU_COUNT}"

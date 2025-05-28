#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -ldeflate"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

# Fix the version
sed -i.bak 's|2.17|2.18|' VERSION
# make check_git_repository
sed -i.bak 's/GIT-NOTFOUND/'$PKG_VERSION' (Bioconda)/' version.h

sed -i.bak 's|VERSION 3.5.1|VERSION 3.5|' CMakeLists.txt
rm -rf *.bak

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CXXFLAGS="${CXXFLAGS} -std=c++14 -D_LIBCPP_DISABLE_AVAILABILITY"
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

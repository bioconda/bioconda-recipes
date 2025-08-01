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

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CXXFLAGS="${CXXFLAGS} -std=c++14 -D_LIBCPP_DISABLE_AVAILABILITY"
else
	export CONFIG_ARGS=""
fi

case $(uname -m) in
    aarch64)
        export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
        ;;
    arm64)
        export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
        ;;
    x86_64)
        export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
        ;;
esac

cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -DBOOST_ROOT="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

# Build & install
ninja -C build install -j "${CPU_COUNT}"

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/aggregateBinDepths.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/aggregateContigOverlapsByBin.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${PREFIX}/bin/merge_depths-DEPRECATED.pl

rm -rf ${PREFIX}/bin/*.bak

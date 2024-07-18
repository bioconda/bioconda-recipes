#!/bin/bash
set -ex

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"

# if [ "$(uname)" == Darwin ]; then
# 	export CMAKE_C_COMPILER="clang"
# 	export CMAKE_CXX_COMPILER="clang++"
# fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DBUILD_GMOCK=OFF -DINSTALL_GTEST=OFF \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli

case $(uname -m) in
aarch64)
	JOBS=1 # CircleCI's arm.medium VM runs out of memory with higher values
	;;
*)
	JOBS=${CPU_COUNT}
	;;
esac

cmake --build build --target install -j "${JOBS}"

chmod 755 "${PREFIX}/bin/cmaple"
chmod 755 "${PREFIX}/bin/cmaple-aa"

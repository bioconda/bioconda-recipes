#!/bin/bash
set -ex

# if [ "$(uname)" == Darwin ]; then
# 	export CMAKE_C_COMPILER="clang"
# 	export CMAKE_CXX_COMPILER="clang++"
# fi

case $(uname -m) in
aarch64)
	JOBS=1 # CircleCI's arm.medium VM runs out of memory with higher values
	;;
*)
	JOBS=${CPU_COUNT}
	;;
esac
JOBS=1 # Simplify logs

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" -G Ninja \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DBUILD_GMOCK=OFF -DINSTALL_GTEST=OFF \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli

VERBOSE=1 cmake --build build --target install -j ${JOBS}

chmod 755 "${PREFIX}/bin/cmaple"
chmod 755 "${PREFIX}/bin/cmaple-aa"

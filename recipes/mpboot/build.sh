#!/bin/bash
set -ex

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -w"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -w"
export CXXFLAGS="${CXXFLAGS} -O3 -w"

if [[ "$(uname)" == Darwin ]]; then
	export CMAKE_C_COMPILER="clang"
	export CMAKE_CXX_COMPILER="clang++"
	export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=11"
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	# `which` is required, as full paths needed
	# see https://github.com/bioconda/bioconda-recipes/pull/49360#discussion_r1686187284
	CC=$(which "$CC")
	CXX=$(which "$CXX")
	AR=$(which "$AR")
	RANLIB=$(which "$RANLIB")
	DCMAKE_ARGS=(-DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}"
		-DCMAKE_CXX_COMPILER_AR="${AR}" -DCMAKE_CXX_COMPILER_RANLIB="${RANLIB}")
else
	export CONFIG_ARGS=""
fi

# On x86 use -DIQTREE_FLAGS=avx, on arm use -DIQTREE_FLAGS=sse4
if [[ "$(uname -m)" == "aarch64" ]]; then
    DCMAKE_ARGS+=(-DIQTREE_FLAGS=sse4)
    EXE_NAME=mpboot-avx
else
    DCMAKE_ARGS+=(-DIQTREE_FLAGS=avx)
    EXE_NAME=mpboot
fi

mkdir build

cd build

cmake -S ../ -B . \
    -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	"${DCMAKE_ARGS[@]}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

# Detect if we are running on CircleCI's arm.medium VM
# If CPU_COUNT is 4, we are on CircleCI's arm.large VM
JOBS=${CPU_COUNT}
if [[ "$(uname -m)" == "aarch64" ]] && [[ "${CPU_COUNT}" -lt 4 ]]; then
	JOBS=1 # CircleCI's arm.medium VM runs out of memory with higher values
fi


VERBOSE=1 make -j "${JOBS}" 

# install
mkdir -p "${PREFIX}/bin"
cp "${EXE_NAME}" "${PREFIX}/bin/"
chmod 0755 "${PREFIX}/bin/${EXE_NAME}"
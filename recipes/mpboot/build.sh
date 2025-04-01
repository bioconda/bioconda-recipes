#!/bin/bash
set -ex

# On x86 use -DIQTREE_FLAGS=avx, on arm use -DIQTREE_FLAGS=sse4
if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
    # DCMAKE_ARGS+=(-DIQTREE_FLAGS=sse4)
    EXE_NAME=mpboot
elif [[ "$(uname -m)" == "x86_64" ]]; then
    DCMAKE_ARGS+=(-DIQTREE_FLAGS=avx)
    EXE_NAME=mpboot-avx
else
    echo "Unsupported architecture: $(uname -m)"
    exit 1
fi

cmake -S . -B . \
    -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${DCMAKE_ARGS[@]}" \
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
cp "${EXE_NAME}" "${PREFIX}/bin/mpboot"
chmod 0755 "${PREFIX}/bin/${EXE_NAME}"
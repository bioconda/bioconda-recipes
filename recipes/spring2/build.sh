#!/bin/bash
set -ex

mkdir -p build
cd build

if [[ "${target_platform}" == "linux-aarch64" ]]; then
	# nasm is x86-only; disable ISA-L (which needs nasm asm) and set baseline march
	PLATFORM_FLAGS=(
		-DLIBRAPIDARCHIVE_WITH_ISAL=OFF
		-DSPRING_ENABLE_IPO=OFF
		"-DCMAKE_C_FLAGS=-march=armv8-a+crc"
		"-DCMAKE_CXX_FLAGS=-march=armv8-a+crc"
	)
elif [[ "${target_platform}" == osx-* ]]; then
	# std::filesystem requires macOS 10.15+; conda-forge osx-64 stdlib defaults MACOSX_DEPLOYMENT_TARGET
	# to 10.13, which prevents cmake from propagating the right version min to compile commands.
	export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-11.0}"
	export CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
	export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
	PLATFORM_FLAGS=("-DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}")
else
	# SPRING_NASM_EXECUTABLE: upstream otherwise prefers its vendored nasm over PATH
	PLATFORM_FLAGS=("-DSPRING_NASM_EXECUTABLE=${BUILD_PREFIX}/bin/nasm")
fi

# OpenMP_ROOT: keep FindOpenMP on the conda prefix instead of Homebrew's libomp
# SPRING_ENABLE_PRECOMPILED_HEADERS=OFF: PCH is incompatible with conda-forge's macOS toolchain
cmake ${CMAKE_ARGS} \
	-DSPRING_ENABLE_COMPILER_CACHE=OFF \
	-DSPRING_ENABLE_PRECOMPILED_HEADERS=OFF \
	-DOpenMP_ROOT="${PREFIX}" \
	"${PLATFORM_FLAGS[@]}" \
	"${SRC_DIR}" || (cat CMakeFiles/CMakeConfigureLog.yaml && exit 1)

cmake --build . --parallel "${CPU_COUNT}" --target spring2
cmake --install .

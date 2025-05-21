#!/bin/bash
set -ex

# AVX might not be supported on all CPUs, in particular Rosetta2 on Apple Silicon
# -march=nocona and -mtune=haswell are the original conda-forge flags
# we're restoring them here by mentioning them explicitly
# .bak is required for sed -i on macOS
sed -i.bak 's/-mavx/-mno-avx -mno-avx2 -march=nocona -mtune=haswell/' cmaple/CMakeLists.txt
rm -rf cmaple/*.bak

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

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release \
	-GNinja -DUSE_LSD2=ON -DIQTREE_FLAGS=omp -DUSE_CMAPLE=ON \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	"${DCMAKE_ARGS[@]}" \
	-DBUILD_GMOCK=OFF -DINSTALL_GTEST=OFF \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

# Detect if we are running on CircleCI's arm.medium VM
# If CPU_COUNT is 4, we are on CircleCI's arm.large VM
JOBS=${CPU_COUNT}
if [[ "$(uname -m)" == "aarch64" ]] && [[ "${CPU_COUNT}" -lt 4 ]]; then
	JOBS=1 # CircleCI's arm.medium VM runs out of memory with higher values
fi

VERBOSE=1 cmake --build build --target install -j "${JOBS}"

chmod 0755 "${PREFIX}/bin/iqtree2"

# Use symlink to not duplicate the binary, saving space
ln -sf "${PREFIX}"/bin/iqtree2 "${PREFIX}"/bin/iqtree

# Remove example data files
for file in "${PREFIX}/example"* "${PREFIX}/models.nex" "${PREFIX}/bin/iqtree2-aa"; do
	if [[ -f "$file" ]]; then
		rm -f "$file"
	fi
done

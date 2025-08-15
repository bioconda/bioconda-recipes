#!/bin/bash
set -ex

# AVX is not supported on all CPUs, in particular Rosetta2 on Apple Silicon
# -march=nocona and -mtune=haswell are the original conda-forge flags
# we're restoring them here by mentioning them explicitly
# .bak is required for sed -i on macOS
sed -i.bak 's/-mavx/-mno-avx -mno-avx2 -march=nocona -mtune=haswell/' CMakeLists.txt

DCMAKE_ARGS=""
if [[ "$(uname)" == Darwin ]]; then
	CC=$(which "$CC")
	CXX=$(which "$CXX")
	AR=$(which "$AR")
	RANLIB=$(which "$RANLIB")
	DCMAKE_ARGS=(-DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}"
		-DCMAKE_CXX_COMPILER_AR="${AR}" -DCMAKE_CXX_COMPILER_RANLIB="${RANLIB}")
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

case $(uname -m) in
aarch64)
	JOBS=1 # CircleCI's arm.medium VM runs out of memory with higher values
	;;
*)
	JOBS=${CPU_COUNT}
	;;
esac

mkdir build
cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -G Ninja \
	"${DCMAKE_ARGS[@]}" \
	-DBUILD_GMOCK=OFF -DINSTALL_GTEST=OFF \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

VERBOSE=1 cmake --build build --target install -j ${JOBS}

chmod 755 "${PREFIX}/bin/cmaple"*

for file in "${PREFIX}/example.maple" "${PREFIX}/tree.nwk"; do
	if [ -f "$file" ]; then
		rm "$file"
	fi
done

#!/bin/bash
set -ex

DCMAKE_ARGS=""
if [ "$(uname)" == Darwin ]; then
	CC=$(which "$CC")
	CXX=$(which "$CXX")
	AR=$(which "$AR")
	RANLIB=$(which "$RANLIB")
	DCMAKE_ARGS=(-DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}"
		-DCMAKE_CXX_COMPILER_AR="${AR}" -DCMAKE_CXX_COMPILER_RANLIB="${RANLIB}")
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
cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" -G Ninja \
	"${DCMAKE_ARGS[@]}" \
	-DBUILD_GMOCK=OFF -DINSTALL_GTEST=OFF \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli

VERBOSE=1 cmake --build build --target install -j ${JOBS}

chmod 755 "${PREFIX}/bin/cmaple"*

for file in "${PREFIX}/example.maple" "${PREFIX}/tree.nwk"; do
    if [ -f "$file" ]; then
        rm "$file"
    fi
done

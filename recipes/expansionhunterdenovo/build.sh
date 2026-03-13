#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

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

mkdir -p "${PREFIX}/bin"

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S source -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

sed -i.bak "s|htslib-NOTFOUND|${PREFIX}/lib/libhts.so|g" build/CMakeFiles/ExpansionHunterDenovo.dir/link.txt
sed -i.bak "s|htslib-NOTFOUND|${PREFIX}/lib/libhts.so|g" build/CMakeFiles/ExpansionHunterDenovo.dir/build.make

cmake --build build -j "${CPU_COUNT}"

install -v -m 0755 build/ExpansionHunterDenovo "${PREFIX}/bin"

chmod +rx scripts/casecontrol/*.py
chmod +rx scripts/core/*.py
chmod +rx scripts/outlier/*.py
chmod +rx scripts/tests/*.py
chmod +rx scripts/*.py
chmod +rx scripts/*.sh

cp -rfv scripts/* "${PREFIX}/bin"

#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p $PREFIX/share/doc/flexbar

wget https://github.com/seqan/seqan/releases/download/seqan-v2.4.0/seqan-library-2.4.0.tar.xz
tar -xf seqan-library-2.4.0.tar.xz

mv seqan-library-2.4.0/include "${SRC_DIR}"

sed -i.bak 's|VERSION 2.8.2|VERSION 3.5|' CMakeLists.txt
sed -i.bak 's|VERSION 2.8.2|VERSION 3.5|' src/CMakeLists.txt

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' src/CMakeLists.txt
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' src/CMakeLists.txt
	;;
esac

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake . -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build . --clean-first -j "${CPU_COUNT}"

install -v -m 0755 flexbar "$PREFIX/bin"
cp -f *.md $PREFIX/share/doc/flexbar

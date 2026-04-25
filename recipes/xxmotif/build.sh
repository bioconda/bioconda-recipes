#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=gnu++11"
export CFLAGS="${CFLAGS} -O3"
export SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

mkdir -p $PREFIX/bin
mkdir -p $SHARE_DIR

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64"
	;;
esac

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cp -rf XXmasker $SHARE_DIR/

ln -s $SHARE_DIR/XXmasker/*.pl ${PREFIX}/bin/

sed -i.bak 's|VERSION 2.8|VERSION 3.5|' CMakeLists.txt
sed -i.bak 's|-std=c99|-std=gnu++11 -march=x86-64|' CMakeLists.txt

case $(uname -m) in
	arm64) sed -i.bak 's|-march=x86-64|-march=armv8.4-a|' CMakeLists.txt ;;
	aarch64) sed -i.bak 's|-march=x86-64|-march=armv8-a|' CMakeLists.txt ;;
esac

rm -f *.bak

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" -Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first -j "${CPU_COUNT}"

"${STRIP}" build/XXmotif

install -v -m 0755 build/XXmotif "$PREFIX/bin"

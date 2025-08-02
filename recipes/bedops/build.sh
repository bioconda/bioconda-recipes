#!/bin/bash
set -eu -o pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	wget https://github.com/alexey-lysiuk/macos-sdk/releases/download/13.3/MacOSX13.3.tar.xz
	tar -xf MacOSX13.3.tar.xz
	cp -rH MacOSX13.3.sdk /Applications/Xcode-15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
	export SDKROOT="/Applications/Xcode-15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk"
	export MACOSX_DEPLOYMENT_TARGET="13.3"
	export MACOSX_SDK_VERSION="13.3"

	#sed -i.bak 's|-static|-static -O3 -march=armv8.4-a|' applications/bed/starch/src/Makefile
fi

make all CC="${CC}" CXX="${CXX}" SFLAGS= -j"${CPU_COUNT}"
make install_all

install -v -m 0755 bin/* "${PREFIX}/bin"

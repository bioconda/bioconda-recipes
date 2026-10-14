#!/usr/bin/env bash

export GOCACHE="$PWD/.cache"
export CGO_ENABLED=1
export GO111MODULE=on
export CGO_LDFLAGS="-L${SRC_DIR}/gominibwa/minibwa -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -g -Wall -Wno-unused-function -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export OS="$(uname -s)"
export ARCH="$(uname -m)"

if [[ "${OS}" == "Darwin" ]]; then
	wget https://github.com/alexey-lysiuk/macos-sdk/releases/download/13.3/MacOSX13.3.tar.xz
	tar -xf MacOSX13.3.tar.xz
	cp -rH MacOSX13.3.sdk /Applications/Xcode-15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
	export SDKROOT="/Applications/Xcode-15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk"
	export CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_OSX_SYSROOT=/Applications/Xcode-15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk"
	export MACOSX_DEPLOYMENT_TARGET=13.0
	export MACOSX_SDK_VERSION=13.0
fi

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

# build minibwa
make CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}" -C gominibwa/minibwa libminibwa.a minibwa

# build arachne
go build -ldflags "-X arachne/aligner.VERSION=${PKG_VERSION} -s -w" -o $PREFIX/bin/arachne

go-licenses save . --save_path="${SRC_DIR}/library_licenses"

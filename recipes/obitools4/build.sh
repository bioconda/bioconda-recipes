#!/bin bash
set -xe

export GOPATH="$PWD"
export GOCACHE="$PWD/.cache"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CGO_LDFLAGS="-L${PREFIX}/lib -lz"
export CGO_CFLAGS="$CGO_CFLAGS -I${PREFIX}/include"

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

sed -i.bak 's|GOFLAGS=|GOFLAGS=-buildvcs=false|' Makefile
rm -f *.bak

if [[ "$(uname -s)" == "Darwin" ]]; then
    wget https://github.com/alexey-lysiuk/macos-sdk/releases/download/13.3/MacOSX13.3.tar.xz
	tar -xf MacOSX13.3.tar.xz
	cp -rH MacOSX13.3.sdk /Applications/Xcode-15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
    export SDKROOT="/Applications/Xcode-15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk"
    export MACOSX_DEPLOYMENT_TARGET="13.0"
    export MACOSX_SDK_VERSION="13.0"
    export CGO_LDFLAGS="-mmacosx-version-min=13.0"
    make CGO_CFLAGS="$CGO_CFLAGS"
else
    make CGO_CFLAGS="$CGO_CFLAGS -L$PREFIX/lib"
fi

install -v -m 0755 build/obi* "${PREFIX}/bin"

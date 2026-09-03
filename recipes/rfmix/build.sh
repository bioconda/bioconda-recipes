#!/bin/bash
# following full suggested build path of rfmix

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

sed -i.bak 's|-lpthread|-pthread|' Makefile.am && rm -f *.bak
if [[ ${target_platform} == "linux-aarch64" ]]; then
	sed -i.bak 's|-march=core2|-march=armv8-a|g' Makefile.am && rm -f *.bak
elif [[ ${target_platform} == "osx-arm64" ]]; then
	sed -i.bak 's|-march=core2|-march=armv8.4-a|g' Makefile.am && rm -f *.bak
fi

autoreconf -if
./configure                  # generates the Makefile
make

# Install
install -v -m 0755 {rfmix,simulate} "${PREFIX}/bin"

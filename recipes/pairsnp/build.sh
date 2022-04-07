
#!/bin/bash

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH=${PREFIX}/include

# conda on macOS will fall back to libstdc++
# which lacks a ton of standard C++11 headers
if [[ $(uname) == Darwin ]]; then
	export CXXFLAGS+="${CXXFLAGS} -stdlib=libc++"
fi

mkdir -p "${PREFIX}/bin"
make CXX="${CXX}" LINK="${CXX}" SWITCHES="${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS}" PREFIX="${PREFIX}"
cp pairsnp ${PREFIX}/bin/
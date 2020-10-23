
#!/bin/bash

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

# conda on macOS will fall back to libstdc++
# which lacks a ton of standard C++11 headers
if [[ $(uname) == Darwin ]]; then
	export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
fi


# depends on automake, autoconf
autoreconf --install
./configure --prefix=$PREFIX
make
make install
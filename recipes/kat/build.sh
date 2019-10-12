#!/bin/sh

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# Build boost
#./build_boost.sh
#importing matplotlib fails, likely due to X
sed -i.bak "124d" configure.ac
sed -i.bak "13d" lib/Makefile.am
sed -i.bak "13i\
	-L${PREFIX}/lib \\" lib/Makefile.am
./autogen.sh
export PYTHON_NOVERSION_CHECK="3.7.0"
./configure --disable-silent-rules --disable-dependency-tracking --prefix=$PREFIX
make
make install

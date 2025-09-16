#!/bin/bash

set -xef -o pipefail

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

./configure --prefix=$PREFIX
make -j ${CPU_COUNT}

if [ -z "${OSX_ARCH}" ]; then
		make check
else
		# on MacOS, for some reason the bambamc dynamic library is not found
		# unless ${PREFIX}/lib is explicitly prepended to the linker search path
		env DYLD_LIBRARY_PATH=${PREFIX}/lib:${DYLD_LIBRARY_PATH} make check
fi

make install


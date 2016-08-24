#!/bin/bash

set -ef -o pipefail

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

./configure --prefix=$PREFIX
make

if [ -z "${OSX_ARCH}" ]; then
		make check
else
		env DYLD_LIBRARY_PATH=${PREFIX}/lib:${DYLD_LIBRARY_PATH} make check
fi

make install


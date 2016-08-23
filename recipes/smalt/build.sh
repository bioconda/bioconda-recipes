#!/bin/bash

set -ef -o pipefail

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"


if [ -z "${OSX_ARCH}" ]; then
		./configure --prefix=$PREFIX
else
		./configure --prefix=$PREFIX --build=x86_64-apple-darwin
fi

make
make check   # fails on osx
make install

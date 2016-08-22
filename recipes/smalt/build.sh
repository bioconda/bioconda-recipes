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
make -d -d -d check   # fails on macos, even though smalt binary seems ok
make install

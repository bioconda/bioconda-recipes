#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I$PREFIX/include"

make
mkdir -p ${PREFIX}
cp bsmap ${PREFIX}/bin

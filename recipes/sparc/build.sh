#!/bin/bash

mkdir -p "$PREFIX/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

"${CXX}" -O3 -o Sparc *.cpp

install -v -m 0755 Sparc "$PREFIX/bin"

sed -i.bak 's|\./||g' utility/split_and_run_sparc.sh
rm -rf utility/*.bak

chmod a+x utility/*.sh

install -v -m 0755 utility/* "$PREFIX/bin"

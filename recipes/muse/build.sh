#!/bin/bash
set -euo pipefail

export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

rm -rf boost_1_70_0/

if [[ `uname` == "Darwin" ]]; then
	ln -sf ${CC} ${PREFIX}/bin/clang
	ln -sf ${CXX} ${PREFIX}/bin/clang++
else
	ln -sf ${CC} ${PREFIX}/bin/gcc
	ln -sf ${CXX} ${PREFIX}/bin/g++
fi

./install_muse.sh

if [[ `uname` == "Darwin" ]]; then
	rm -rf ${PREFIX}/bin/clang
	rm -rf ${PREFIX}/bin/clang++
else
	rm -rf ${PREFIX}/bin/gcc
	rm -rf ${PREFIX}/bin/g++
fi

install -d "${PREFIX}/bin"
install -v -m 0755 MuSE "${PREFIX}/bin"

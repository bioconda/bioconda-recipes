#!/bin/bash

case "$(uname -s)" in
    Darwin)
	export MD5="md5 -r";;
    Linux)
	export MD5="md5sum";;
    *)
	echo "Not supported";;
esac
	
autoreconf -fi
export CXXFLAGS="${CXXFLAGS} -fsigned-char -std=c++14"
export CFLAGS="${CFLAGS} -fsigned-char"
./configure --prefix=$PREFIX
make -j ${CPU_COUNT}
make install

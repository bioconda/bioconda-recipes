#!/bin/bash
set -x

export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib -ldeflate"
export CPATH="$PREFIX/include"
export CC="${CC} -fcommon"
export CXX="${CXX} -fcommon"

mkdir -p "$PREFIX/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* libs/htslib/

sed -i.bak 's|-lpthread|-pthread|' libs/seq_file/dev/Makefile
sed -i.bak 's|-Wextra -I ..|-O3 -I .. -I $(PREFIX)/include|' libs/seq_file/dev/Makefile
sed -i.bak 's|-lpthread|-pthread|' libs/seq_file/benchmarks/Makefile
sed -i.bak 's|-Wextra -I ..|-O3 -I .. -I $(PREFIX)/include|' libs/seq_file/benchmarks/Makefile

for make_file in libs/string_buffer/Makefile $(find libs/seq_file -name Makefile) $(find libs/seq-align -name Makefile) Makefile; do
	sed -i.bak 's/-lz/-lz $(LDFLAGS)/' $make_file
done

case $(uname -m) in
    aarch64|arm64)
	for make_file in libs/string_buffer/Makefile $(find libs/seq_file -name Makefile) $(find libs/seq-align -name Makefile) Makefile; do
		sed -i.bak 's/-m64//' $make_file
	done
	;;
esac

make MAXK=31
make MAXK=63
make MAXK=95
make MAXK=127

sed -i.bak '1 s|^.*$|#!/usr/bin/env bash|g' bin/mccortex && rm -f bin/*.bak

install -v -m 0755 bin/* "$PREFIX/bin"

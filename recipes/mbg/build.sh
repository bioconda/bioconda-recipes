#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ `uname -s` == "Darwin" ]]; then
	sed -i.bak 's|-Wl,-Bstatic||' makefile
fi

sed -i.bak 's|-Izstr/src|-I$(PREFIX)/include -Izstr/src|' makefile
sed -i.bak 's|LIBS=`|LIBS=-L$(PREFIX)/lib `|' makefile
sed -i.bak 's|-lpthread||' makefile
rm -rf *.bak

make -j"${CPU_COUNT}" bin/MBG
install -v -m 755 bin/MBG "${PREFIX}/bin"

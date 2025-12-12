#!/bin/bash
set -eu -o pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX/bin"

sed -i.bak 's/gcc/$(CC)/g' source/Makefile
sed -i.bak 's/-m64//g' source/Makefile
rm -f source/*.bak

cd source

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 fastuniq "$PREFIX/bin"

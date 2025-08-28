#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"

if [[ "$target_platform" == osx-* ]]; then
    for toolname in "otool" "install_name_tool"; do
        tool=$(find "${BUILD_PREFIX}/bin/" -name "*apple*-$toolname")
        mv "${tool}" "${tool}.bak"
        ln -s "/Library/Developer/CommandLineTools/usr/bin/${toolname}" "$tool"
    done
fi

autoreconf -if
./configure --prefix=$PREFIX

make -j"${CPU_COUNT}"
make install

cd python
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 --report record.txt

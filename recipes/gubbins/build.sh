#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

if [[ $target_platform == osx-* ]]; then
    for toolname in "otool" "install_name_tool"; do
        tool=$(find "${BUILD_PREFIX}/bin/" -name "*apple*-$toolname")
        mv "${tool}" "${tool}.bak"
        ln -s "/Library/Developer/CommandLineTools/usr/bin/${toolname}" "$tool"
    done
fi

autoreconf -i
./configure --prefix=$PREFIX
make -j"${CPU_COUNT}"
make install
cd python
$PYTHON -m pip install . --report record.txt

#!/bin/bash
set -euo pipefail
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
sed -i -e 's/-march=i686/-march=native/' ./source/Makefile
cd ./source

if [ ! -f Makefile ]; then
    echo "Makefile not found!"
fi

make

if [ ! -f dialign-txt ]; then
    echo "dialign-tx not found!"
fi

mv dialign-tx $PREFIX/bin/


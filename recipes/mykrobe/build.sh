#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export CPPFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"

if [[ "$(uname)" == "Linux" ]] ; then
    export LDFLAGS="$LDFLAGS -Wl,--add-needed"
fi

# cd "$SRC_DIR"

wget https://bit.ly/2H9HKTU -O - | tar -vxzf  -
rm -fr src/mykrobe/data
mv mykrobe-data src/mykrobe/data
pip install .

# $PYTHON setup.py install --single-version-externally-managed --record=record.txt

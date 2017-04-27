#!/bin/bash
set -eu

if [[ "${PY_VER}" =~ 3 ]]
then
    2to3 -wn .
    echo "LoFreq python scripts have been automatically ported from python 2 to 3 using 2to3.
Thorough testing is left to the user." > $PREFIX/.messages.txt
fi

mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin


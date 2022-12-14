#!/bin/bash

if [ "$(uname)" == "Darwin" ];
then
    sed -i.bak1 's/g++/${CXX}/g' makefile
    sed -i.bak2 's/astral-hybrid astral-hybrid_precise //g' makefile
    make
else
    sed -i.bak 's/g++/${GXX}/g' makefile
    make
fi

[ ! -d $PREFIX/bin ] && mkdir -p $PREFIX/bin

cp bin/astral $PREFIX/bin/
cp bin/astral-pro $PREFIX/bin/
cp bin/asterisk $PREFIX/bin/

chmod a+x $PREFIX/bin/astral
chmod a+x $PREFIX/bin/astral-pro
chmod a+x $PREFIX/bin/asterisk


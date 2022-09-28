#!/bin/bash

make

[ ! -d $PREFIX/bin ] && mkdir -p $PREFIX/bin

cp bin/astral $PREFIX/bin
cp bin/astral-pro $PREFIX/bin
cp bin/asterisk $PREFIX/bin

chmod a+x $PREFIX/bin/astral
chmod a+x $PREFIX/bin/astral-pro
chmod a+x $PREFIX/bin/asterisk


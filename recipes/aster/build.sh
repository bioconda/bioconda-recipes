#!/bin/bash

make

if [ ! -d $PREFIX/bin ] ; then
	mkdir -p $PREFIX/bin
fi

cp astral $PREFIX/bin
cp astral-pro $PREFIX/bin
cp asterisk $PREFIX/bin
chmod a+x $PREFIX/bin/astral
chmod a+x $PREFIX/bin/astral-pro
chmod a+x $PREFIX/bin/asterisk


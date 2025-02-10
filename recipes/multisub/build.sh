#!/bin/sh

if [ ! -d $PREFIX/bin ] ; then
    mkdir $PREFIX/bin
fi

cp multiSub $PREFIX/bin
chmod 700 $PREFIX/bin/multiSub

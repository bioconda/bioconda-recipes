#!/bin/bash

if [ $(uname) == Linux ]; then
    ar vx pandoc*.deb
    tar -xzvf data.tar.gz
    mkdir -p $PREFIX/bin
    mv usr/bin/* $PREFIX/bin
fi


if [ $(uname) == Darwin ]; then
    pkgutil --expand pandoc-$PKG_VERSION.pkg pandoc
    cpio -i -I pandoc/pandoc.pkg/Payload
    mkdir -p $PREFIX/bin
    cp usr/local/bin/* $PREFIX/bin/
fi

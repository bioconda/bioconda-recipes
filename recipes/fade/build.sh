#!/bin/bash

if [ "$(uname)" != "Darwin" ]; then
    echo "Linux: static binary"
    cd $SRC_DIR
    mkdir -p $PREFIX/bin
    cp fade $PREFIX/bin
else
    echo "MacOS: shared binary"
    echo "Downloading and installing parasail"
    # download and install parasail
    wget https://github.com/jeffdaily/parasail/releases/download/v2.4.3/parasail-2.4.3-Darwin-10.13.6.tar.gz
    tar -xzf parasail-2.4.3*.tar.gz
    cp -r parasail-2.4.3*/lib/* $PREFIX/lib

    cd $SRC_DIR
    mkdir -p $PREFIX/bin
    cp fade $PREFIX/bin

fi


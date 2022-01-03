#!/bin/bash

# download and install parasail

if [ "$(uname)" != "Darwin" ]; then
    echo "Linux: download static binary"
    wget https://github.com/blachlylab/fade/releases/download/v0.5.3/fade
    chmod +x ./fade
    cp fade $PREFIX/bin
else
    echo "MacOS: so we must build"
    echo "Downloading and installing parasail"
    # Install parasail
    wget https://github.com/jeffdaily/parasail/releases/download/v2.4.3/parasail-2.4.3-Darwin-10.13.6.tar.gz
    tar -xzf parasail-2.4.3*.tar.gz
    cp -r parasail-2.4.3*/lib/* $PREFIX/lib

    wget https://github.com/dlang/dub/releases/download/v1.23.0/dub-v1.23.0-osx-x86_64.tar.gz
    tar -xzf dub-v1.23.0-osx-x86_64.tar.gz
    chmod +x ./dub

    # build fade binary
    cd $SRC_DIR
    echo "building fade binary"

    export LIBRARY_PATH="$PREFIX/lib:$LIBRARY_PATH"
    export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"

    dub build -b release -c bioconda
    cp ldc-1.26.0/lib/* $PREFIX/lib
    deactivate    

    # run binary as test and move binary to bin
    ./fade
    cp fade $PREFIX/bin
fi


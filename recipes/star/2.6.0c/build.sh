#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing STAR for OSX."
    mkdir -p $PREFIX/bin
    cp bin/MacOSX_x86_64/* $PREFIX/bin
else 
    echo "Installing STAR for UNIX/Linux."
    mkdir -p $PREFIX/bin
    cp bin/Linux_x86_64_static/* $PREFIX/bin
fi

#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing SolexaQA++ for OSX."
    mkdir -p $PREFIX/bin
    cp MacOs_10.7+/* $PREFIX/bin
else 
    echo "Installing SolexaQA++ for UNIX/Linux."
    mkdir -p $PREFIX/bin
    cp Linux_x64/* $PREFIX/bin
fi

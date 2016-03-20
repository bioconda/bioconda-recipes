#!/bin/bash
if [ `uname` == "Darwin" ]; then
    echo "Installing SolexaQA++ for OSX."
    mkdir -p $PREFIX/bin
    mv MacOs_10.7+/SolexaQA++ $PREFIX/bin
else 
    echo "Installing SolexaQA++ for UNIX/Linux."
    mkdir -p $PREFIX/bin
    mv Linux_x64/SolexaQA++ $PREFIX/bin
fi

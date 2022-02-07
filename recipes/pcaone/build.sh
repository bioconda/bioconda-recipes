#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
cp PCAone ${PREFIX}/bin

# Set up build environment
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"

# put runtime lib into user's env
[ -f $HOME/.bashrc ] && echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$PREFIX/lib\"" >> $HOME/.bashrc
[ -f $HOME/.zshrc ] && echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$PREFIX/lib\"" >> $HOME/.zshrc


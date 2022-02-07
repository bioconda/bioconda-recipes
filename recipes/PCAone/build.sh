#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
cp PCAone ${PREFIX}/bin
# put runtime lib into user's env

# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PREFIX/lib"

[ -f $HOME/.bashrc ] && echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$PREFIX/lib\"" >> $HOME/.bashrc
[ -f $HOME/.zshrc ] && echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$PREFIX/lib\"" >> $HOME/.zshrc


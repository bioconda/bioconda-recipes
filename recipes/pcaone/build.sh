#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
cp PCAone ${PREFIX}/bin

# Set up build environment
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
# on mac, add conda lib to @rpath
if [ "$(uname)" == "Darwin" ]; then
    install_name_tool -add_rpath ${PREFIX}/lib PCAone
fi

# put runtime lib into user's env
# [ -f $HOME/.bashrc ] && echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$PREFIX/lib\"" >> $HOME/.bashrc
# [ -f $HOME/.zshrc ] && echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$PREFIX/lib\"" >> $HOME/.zshrc


#!/bin/bash
mkdir -p "$PREFIX/bin"
if [ "$(uname)" == "Darwin" ]; then
    cp -p mga_osx "$PREFIX/bin/mga"
else
    cp -p mga_linux_ia64 "$PREFIX/bin/mga"
fi

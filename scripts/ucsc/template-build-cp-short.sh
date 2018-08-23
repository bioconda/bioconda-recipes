#!/bin/bash
mkdir -p "$PREFIX/bin"
if [ "$(uname)" == "Darwin" ]; then
    cp {program} "$PREFIX/bin"
else
    cp kent/src/utils/{program} "$PREFIX/bin"
fi
chmod +x "$PREFIX/bin/{program}"

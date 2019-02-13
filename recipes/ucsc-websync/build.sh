#!/bin/bash
mkdir -p "$PREFIX/bin"
if [ "$(uname)" == "Darwin" ]; then
    cp webSync "$PREFIX/bin"
else
    cp kent/src/utils/webSync "$PREFIX/bin"
fi
chmod +x "$PREFIX/bin/webSync"

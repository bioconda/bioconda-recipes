#!/bin/bash
mkdir -p "$PREFIX/bin"
cp kent/src/utils/{program} "$PREFIX/bin"
chmod +x "$PREFIX/bin/{program}"

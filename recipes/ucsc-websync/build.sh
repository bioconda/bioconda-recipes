#!/bin/bash
mkdir -p "$PREFIX/bin"
cp kent/src/utils/webSync "$PREFIX/bin"
chmod +x "$PREFIX/bin/webSync"

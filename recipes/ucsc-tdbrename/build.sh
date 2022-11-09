#!/bin/bash
mkdir -p "$PREFIX/bin"
cp kent/src/utils/tdbRename "$PREFIX/bin"
chmod +x "$PREFIX/bin/tdbRename"

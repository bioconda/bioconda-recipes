#!/bin/bash
mkdir -p "$PREFIX/bin"
cp kent/src/utils/tdbSort "$PREFIX/bin"
chmod +x "$PREFIX/bin/tdbSort"

#!/bin/bash
mkdir -p "$PREFIX/bin"
cp kent/src/utils/bigHeat "$PREFIX/bin"
chmod +x "$PREFIX/bin/bigHeat"

#!/usr/bin/env bash
set -ex


mkdir -p "$PREFIX/share/knotAnnotSV"
cp -R -- * "$PREFIX/share/knotAnnotSV"

mkdir -p "$PREFIX/bin"
cp "$PREFIX/share/knotAnnotSV"/*.pl "$PREFIX/bin"
# Required otherwise no macro will be associated in the output:
cp "$PREFIX/share/knotAnnotSV/vbaProject.bin" "$PREFIX/bin"

chmod +x "$PREFIX"/bin/*

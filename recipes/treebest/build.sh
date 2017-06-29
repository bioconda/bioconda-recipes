#!/bin/sh
set -e

make
mkdir -p "$PREFIX/bin"
cp treebest "$PREFIX/bin/"

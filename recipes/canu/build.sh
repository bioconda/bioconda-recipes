#!/bin/bash

# fail on all errors
set -e

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib"
mkdir -p "$PREFIX/share"

cp -r bin/* $PREFIX/bin/
cp -r lib/* $PREFIX/lib/
cp -r share/* $PREFIX/share/

#!/bin/bash

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib/ecmsd/shell"
mkdir -p "$PREFIX/lib/ecmsd/scripts"

cp shell/ECMSD.sh "$PREFIX/lib/ecmsd/shell/ECMSD.sh"
cp shell/MakeRef.sh "$PREFIX/lib/ecmsd/shell/MakeRef.sh"
cp scripts/*.py "$PREFIX/lib/ecmsd/scripts/"
cp scripts/*.R "$PREFIX/lib/ecmsd/scripts/"

cp shell/ECMSD.sh "$PREFIX/bin/ECMSD"
chmod +x "$PREFIX/bin/ECMSD"

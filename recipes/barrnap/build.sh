#!/usr/bin/env bash
set -eux -o pipefail

EXE="barrnap"
DESTDIR="$PREFIX/lib/$EXE"
mkdir -p "$DESTDIR"
mkdir -p "$PREFIX/bin"
cp -av * "$DESTDIR/"
ln -s "$DESTDIR/bin/$EXE" "$PREFIX/bin/$EXE"

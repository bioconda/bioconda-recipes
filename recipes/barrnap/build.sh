#!/usr/bin/env bash
set -eux -o pipefail

EXE="barrnap"

DESTDIR="$PREFIX/lib/$EXE"
mkdir -p "$DESTDIR"
cp -av * "$DESTDIR/"

mkdir -p "$PREFIX/bin"
ln -s "$DESTDIR/bin/$EXE" "$PREFIX/bin/$EXE"

"$DESTDIR/bin/$EXE" --updatedb

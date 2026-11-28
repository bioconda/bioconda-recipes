#!/usr/bin/env bash

mkdir -p $PREFIX/bin/ $PREFIX/lib/mmlong2-lite
cp -r src $PREFIX/lib/mmlong2-lite
ln -s ../lib/mmlong2-lite/src/mmlong2-lite.sh $PREFIX/bin/mmlong2-lite
chmod +x $PREFIX/bin/mmlong2-lite

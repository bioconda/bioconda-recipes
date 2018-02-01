#!/bin/bash
set -e

cp LICENSE $PREFIX/
cp README $PREFIX/

mkdir -p "$PREFIX/bin"

cp bin/*.py $PREFIX/bin/
chmod u+x $PREFIX/bin/*.py

mkdir -p "$PREFIX/deepsiglib"
cp deepsig/lib/python2.7/site-packages/deepsiglib/*.py $PREFIX/deepsiglib/

mkdir -p "$PREFIX/models"
cp -r models/ $PREFIX/models/

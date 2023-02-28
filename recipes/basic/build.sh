#!/bin/bash

mkdir -p $PREFIX/db/basic
mkdir -p $PREFIX/bin
cp -rf db/* $PREFIX/db/basic/

# replace /db/ path with /../db/basic/
sed 's;"db");"../db/basic");g' BASIC.py > $PREFIX/bin/BASIC.py
chmod +x $PREFIX/bin/BASIC.py

#!/bin/bash

mkdir -p $PREFIX/bin
cp phirbo.py $PREFIX/bin/phirbo.py
ln $PREFIX/bin/phirbo.py $PREFIX/bin/phirbo
chmod +x $PREFIX/bin/phirbo.py $PREFIX/bin/phirbo

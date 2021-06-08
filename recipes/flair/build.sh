#!/bin/bash

mkdir -p $PREFIX/bin
cp flair.py $PREFIX/bin/
chmod +x $PREFIX/bin/flair.py

mkdir -p $PREFIX/bin/bin
cp bin/*.py $PREFIX/bin/bin/


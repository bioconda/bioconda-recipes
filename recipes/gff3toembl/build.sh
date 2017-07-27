#!/bin/bash

mkdir -p "$PREFIX/bin/"

mv * "$PREFIX/bin/"

python $PREFIX/bin/setup.py install

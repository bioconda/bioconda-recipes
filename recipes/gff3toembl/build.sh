#!/bin/bash

mkdir -p "$PREFIX/home"
mv * "$PREFIX/bin/"
python setup.py install

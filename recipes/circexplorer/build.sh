#!/bin/bash

$PYTHON -m pip install . --ignore-installed --no-deps -vv
cp -rf circ/* $PREFIX/bin

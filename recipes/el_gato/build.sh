#!/bin/bash

$PYTHON -m pip install . -vv

mkdir -p $PREFIX/bin/db
cp el_gato/db/* $PREFIX/bin/db/

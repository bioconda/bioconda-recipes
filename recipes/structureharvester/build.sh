#!/bin/bash

mkdir -p $PREFIX/bin
cp $SRC_DIR/*.py $PREFIX/bin && chmod +x $PREFIX/bin/structureHarvester.py


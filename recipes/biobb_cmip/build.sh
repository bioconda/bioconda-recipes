#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_cmip/cmip/cmip.py
cp $SP_DIR/biobb_cmip/cmip/cmip.py $PREFIX/bin/biobbcmip

chmod u+x $SP_DIR/biobb_cmip/cmip/titration.py
cp $SP_DIR/biobb_cmip/cmip/titration.py $PREFIX/bin/titration

#!/bin/sh
nimble build -y --verbose
cp strling $PREFIX/bin/strling
cp scripts/strling-outliers.py $PREFIX/bin/
# TODO: copy python scripts

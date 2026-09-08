#!/bin/sh

python -m pip install . -vv --no-deps --no-build-isolation
cp $RECIPE_DIR/wrapper.sh $PREFIX/bin/spectrseqtools



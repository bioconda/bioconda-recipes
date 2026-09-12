#!/bin/sh

python -m pip install . -vv --no-deps --no-build-isolation
script=$PREFIX/bin/spectrseqtools
cp $RECIPE_DIR/wrapper.sh $script
chmod +x $script




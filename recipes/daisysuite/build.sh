#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/daisysuite/

# Full path to the Snakefile/scripts
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/daisysuite|g" DaisySuite
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/daisysuite|g" DaisySuite_stats
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/daisysuite|g" DaisySuite_setup

cp -r * $PREFIX/opt/daisysuite/
ln -s $PREFIX/opt/daisysuite/DaisySuite $PREFIX/bin/
ln -s $PREFIX/opt/daisysuite/DaisySuite_setup $PREFIX/bin/
ln -s $PREFIX/opt/daisysuite/DaisySuite_stats $PREFIX/bin/

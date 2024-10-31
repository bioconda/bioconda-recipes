#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/daisysuite/

# Full path to the Snakefile/scripts
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/daisysuite|g" DaisySuite
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/daisysuite|g" DaisySuite_stats
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/daisysuite|g" DaisySuite_setup
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/daisysuite|g" DaisySuite_example
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/daisysuite|g" DaisySuite_template

cp -r * $PREFIX/opt/daisysuite/
ln -s $PREFIX/opt/daisysuite/DaisySuite $PREFIX/bin/
ln -s $PREFIX/opt/daisysuite/DaisySuite_setup $PREFIX/bin/
ln -s $PREFIX/opt/daisysuite/DaisySuite_stats $PREFIX/bin/
ln -s $PREFIX/opt/daisysuite/DaisySuite_example $PREFIX/bin/
ln -s $PREFIX/opt/daisysuite/DaisySuite_template $PREFIX/bin/

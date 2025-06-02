#!/usr/bin/env bash

# copying over all necessary files
mkdir -p $PREFIX/bin/
chmod a+x run_metabinner.sh
cp run_metabinner.sh $PREFIX/bin/
cp -r auxiliary $PREFIX/bin/
cp -r scripts $PREFIX/bin/

## Original build by author just placed directories in bin, not scripts themsleves
## To ensure backwards compatibility, we additionally symlink the scripts to the bin directory
ln -s $PREFIX/bin/auxiliary/* $PREFIX/bin/
ln -s $PREFIX/bin/scripts/* $PREFIX/bin/

#!/usr/bin/env bash

# copying over all necessary files
mkdir -p $PREFIX/bin/
chmod a+x run_metabinner.sh
cp run_metabinner.sh $PREFIX/bin/
cp -r auxiliary $PREFIX/bin/
cp -r scripts $PREFIX/bin/

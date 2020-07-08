#!/bin/bash

this_dir=$(basename $(pwd))
cd ..
cp -r $this_dir $PREFIX/merqury

mkdir -p $PREFIX/bin
cd $PREFIX/bin
ln -s ../merqury/merqury.sh

# https://docs.conda.io/projects/conda-build/en/latest/resources/activate-scripts.html
# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    for EXT in "sh" "fish"
    do
        cp "${RECIPE_DIR}/${CHANGE}.$EXT" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.$EXT"
    done
done


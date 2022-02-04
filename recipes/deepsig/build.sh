#!/bin/bash

python -m pip install --no-deps --ignore-installed .

mkdir -p $PREFIX/share/deepsig/
cp -r models/ $PREFIX/share/deepsig/
cp -r tools/ $PREFIX/share/deepsig/

# add de/activation scripts to set the DEEPSIG_ROOT env var
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

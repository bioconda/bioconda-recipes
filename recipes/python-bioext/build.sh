#!/bin/bash

if [ `uname -s` == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

export FREETYPE2_ROOT=$PREFIX

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

# Symlink reference data to /usr/local/share, since the site-packages path may vary depending on python version
mkdir -p "${PREFIX}/usr/local/share/bealign_references"
ln -s "$SP_DIR/BioExt/data/references/hxb2" "$PREFIX/usr/local/share/bealign_references/HXB2"
ln -s "$SP_DIR/BioExt/data/references/cov2" "$PREFIX/usr/local/share/bealign_references/CoV2"
ln -s "$SP_DIR/BioExt/data/references/nl4-3" "$PREFIX/usr/local/share/bealign_references/NL4-3"

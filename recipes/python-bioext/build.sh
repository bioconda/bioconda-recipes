#!/bin/bash

if [ `uname -s` == "Darwin" ]; then
    export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi

export FREETYPE2_ROOT=$PREFIX

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"

TARGET=$PREFIX/share/$PKG_NAME/reference_data

# Symlink reference data to /usr/local/share/$TARGET, since the site-packages
# path may vary depending on the python version
mkdir -p "$TARGET"
ln -s "$SP_DIR/BioExt/data/references" "$TARGET"

echo "export BEALIGN_REFERENCE_DIR=$TARGET" > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
echo "unset BEALIGN_REFERENCE_DIR" > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"

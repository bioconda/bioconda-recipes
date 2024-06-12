#!/bin/bash

$PYTHON -m pip install .

CMAT="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${PREFIX}/bin ${CMAT}

chmod 775 bin/cmat/*
cp bin/cmat/* ${PREFIX}/bin

mv bin/ mappings/ pipelines/ ${CMAT}
#!/bin/bash -euo

$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv

CMAT="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${PREFIX}/bin ${CMAT}

chmod 775 bin/cmat/*
cp -f bin/cmat/* ${PREFIX}/bin

mv bin/ mappings/ pipelines/ ${CMAT}

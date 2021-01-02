#!/bin/bash
BACTOPIA_VERSION="${PKG_VERSION%.*}.x"
BACTOPIA="${PREFIX}/share/${PKG_NAME}-${BACTOPIA_VERSION}"
mkdir -p ${PREFIX}/bin ${BACTOPIA}

chmod 777 bactopia
mv bactopia ${PREFIX}/bin

chmod 777 bin/helpers/*.py
mv bin/helpers/*.py ${PREFIX}/bin

# Move bactopia nextflow
mv bin/ conda/ conf/ docs/ templates/ tools/ main.nf nextflow.config ${BACTOPIA}

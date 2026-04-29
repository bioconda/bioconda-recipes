#!/bin/bash
BACTOPIA="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${PREFIX}/bin ${BACTOPIA}

chmod 775 bin/*
cp bin/* ${PREFIX}/bin

# Move bactopia nextflow
mv bin/ conf/ data/ modules/ subworkflows/ tests/ workflows/ main.nf catalog.json nextflow.config nextflow_schema.json ${BACTOPIA}


#!/bin/bash
CLADEBREAKER_VERSION="${PKG_VERSION%.*}.x"
CLADEBREAKER="${PREFIX}/share/${PKG_NAME}-${CLADEBREAKER_VERSION}"
mkdir -p ${PREFIX}/bin ${CLADEBREAKER}

chmod 775 bin/*.py
cp bin/*.py ${PREFIX}/bin

chmod 775 bin/cladebreaker/*
cp bin/cladebreaker/* ${PREFIX}/bin

mv bin/ conf/ data/ lib/ modules/ subworkflows/ workflows/ assets/ main.nf nextflow_schema.json nextflow.config ${CLADEBREAKER}
# mv bin/ conda/ conf/ data/ lib/ modules/ subworkflows/ tests/ workflows/ main.nf nextflow.config ${CLADEBREAKER}
# $PYTHON setup.py install     # Python command to install the script.

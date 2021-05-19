#!/bin/bash

VARIPHYER="${PREFIX}/share/${PKG_NAME}"
mkdir -p ${PREFIX}/bin ${VARIPHYER}

chmod 777 variphyer
mv variphyer ${PREFIX}/bin

# Move bactopia nextflow
mv main.nf nextflow.config ${VARIPHYER}
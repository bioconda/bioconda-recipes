#! /bin/bash

# Set up defaults
PBPTYPER_SHARE="share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${PREFIX}/${PBPTYPER_SHARE}
mkdir -p ${PREFIX}/bin

# Make Bioconda compatible
mv db/OSAdb.fasta ${PREFIX}/${PBPTYPER_SHARE}/
sed "s=\"bin\", \"db\"=\"bin\", \"$PBPTYPER_SHARE\"/a=" bin/pbptyper > ${PREFIX}/bin/pbptyper
chmod 755 ${PREFIX}/bin/pbptyper

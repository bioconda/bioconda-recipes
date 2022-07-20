#! /bin/bash

# Set up defaults
PASTY_SHARE="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${PASTY_SHARE}
mkdir -p ${PREFIX}/bin

# Make Bioconda compatible
mv db/OSAdb.fasta ${PASTY_SHARE}/
sed "s=db/OSAdb.fasta=$PASTY_SHARE/OSAdb.fasta=" bin/pasty > ${PREFIX}/bin/pasty
chmod 755 ${PREFIX}/bin/pasty

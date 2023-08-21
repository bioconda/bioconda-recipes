#! /bin/bash

# Set up defaults
PASTY_SHARE="share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${PREFIX}/${PASTY_SHARE}
mkdir -p ${PREFIX}/bin

# Make Bioconda compatible
mv db/OSAdb.fasta ${PREFIX}/${PASTY_SHARE}/
sed "s=db/OSAdb.fasta=$PASTY_SHARE/OSAdb.fasta=" bin/pasty > ${PREFIX}/bin/pasty
chmod 755 ${PREFIX}/bin/pasty

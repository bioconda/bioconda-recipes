#!/bin/bash

# Run setup.sh
./setup.sh


# Set variables
TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"


# Copy scripts
cp *.pl ${PREFIX}/bin/
cp *.R ${PREFIX}/bin/
ln -s ${PREFIX}/bin/MitoSAlt1.1.1.pl ${PREFIX}/bin/mitosalt.pl
ln -s ${PREFIX}/bin/MitoSAlt_SE1.1.1.pl ${PREFIX}/bin/mitosalt_se.pl
chmod +x ${PREFIX}/bin/*.pl
chmod +x ${PREFIX}/bin/*.R


# Copy programs built in meta.yaml
cp bin/faSize ${PREFIX}/bin/
cp bin/faSomeRecords ${PREFIX}/bin/
cp bin/bedGraphToBigWig ${PREFIX}/bin/
cp bin/sambamba ${PREFIX}/bin/
cp -r bin/bbmap ${PREFIX}/bin/
cp bin/hisat2/hisat2 bin/hisat2/hisat2-align-s bin/hisat2/hisat2-align-l bin/hisat2/hisat2-build bin/hisat2/hisat2-build-s bin/hisat2/hisat2-build-l bin/hisat2/hisat2-inspect bin/hisat2/hisat2-inspect-s bin/hisat2/hisat2-inspect-l ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/hisat2*
chmod +x ${PREFIX}/bin/bbmap/*.sh
chmod +x ${PREFIX}/bin/faSize ${PREFIX}/bin/faSomeRecords ${PREFIX}/bin/bedGraphToBigWig
chmod +x ${PREFIX}/bin/sambamba
ln -s ${PREFIX}/bin/bbmap/*.sh ${PREFIX}/bin/


# Copy config files
cp *.txt ${TGT}


# Copy script to download database
mkdir -p $TGT/db/genome
touch $TGT/db/genome/.tmp
cp ${RECIPE_DIR}/download-mitosalt-db.sh ${PREFIX}/bin
chmod +x ${PREFIX}/bin/download-mitosalt-db.sh


# set MITOSALT_DATA variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/mitosalt.sh
export MITOSALT_DATA=${TGT}/db/
export MITOSALT_CONFIG_FILE=${TGT}
export CONDA_ENV_BIN=${PREFIX}/bin/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/mitosalt.sh
unset MITOSALT_DATA
unset MITOSALT_CONFIG_FILE
unset CONDA_ENV_BIN
EOF

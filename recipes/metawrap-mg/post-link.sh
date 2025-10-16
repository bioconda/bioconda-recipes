#!/bin/bash

set -eux

echo PKG_NAME $PKG_NAME > $PREFIX/.messages.txt

echo "====================== ENV ==================" >> $PREFIX/.messages.txt
env >> $PREFIX/.messages.txt
echo "====================== ENV ==================" >> $PREFIX/.messages.txt
 

# # Only execute for the binning, refinement, and reassemble-bins subpackages
# # ie those that use checkm
if [[ "$PKG_NAME" != "metawrap-mg-binning" && "$PKG_NAME" != "metawrap-mg-refinement" && "$PKG_NAME" != "metawrap-mg-reassemble-bins" ]]; then
    echo WRONG PKG_NAME $PKG_NAME >> $PREFIX/.messages.txt
fi

CHECKM_DIR="${PREFIX}/etc/checkm"
FN="checkm_data.tar.gz"
MD5="631012fa598c43fdeb88c619ad282c4d" # md5 is provided by zenodo
URL="https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz"

# create staging area
STAGING="${PREFIX}/staging"
mkdir -p "${STAGING}"
TARBALL="${STAGING}/${FN}"

# download the reference data
wget -O "${TARBALL}" "${URL}"
# md5sum -c <<< "${MD5} ${TARBALL}" || exit 1
md5sum "${TARBALL}"

# expand the database
mkdir -p "${CHECKM_DIR}"
tar -zxf "${TARBALL}" \
	-C "${CHECKM_DIR}" \
	--strip-components 1

# update the config
echo "${CHECKM_DIR}"	\
    | checkm data setRoot "${CHECKM_DIR}"

# tidy up
rm -r "${STAGING}"

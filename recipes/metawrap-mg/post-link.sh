#!/bin/bash

set -eux

# this will install checkm reference data upon installation
#
# the if checks if checkm binary is installed, otherwise
# the reference data (1.4G) will be installed in the containers
# of all outputs of the recipe
# 
# newer checkm conda packages do this itself, for backward
# compatibility we keep this here (ideally this would not be
# part of any recipe)

if command -v checkm >/dev/null 2>&1; then
    
	echo "installing checkm reference data" > $PREFIX/.messages.txt

	CHECKM_DIR="${PREFIX}/etc/checkm"
	FN="checkm_data.tar.gz"
	MD5="631012fa598c43fdeb88c619ad282c4d" # md5 is provided by zenodo
	URL="https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz"

	# create staging area
	STAGING="${PREFIX}/staging"
	mkdir -p "${STAGING}"
	TARBALL="${STAGING}/${FN}"

	# download the reference data
	curl -L -o "${TARBALL}" "${URL}"
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

fi
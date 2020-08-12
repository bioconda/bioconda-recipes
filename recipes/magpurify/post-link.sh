#!/usr/bin/env bash

cat  >> "${PREFIX}/.messages.txt" <<EOF
####################################################################################
${PKG_NAME} version ${PKG_VERSION}-${PKG_BUILDNUM} has been successfully installed!

This package needs a database wich can be downloaded from:
https://zenodo.org/record/3688811/files/MAGpurify-db-v1.0.tar.bz2
unzip the database and make it available in the MAGPURIFYDB environmental variable

EOF

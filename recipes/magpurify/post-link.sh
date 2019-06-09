#!/usr/bin/env bash

echo "
####################################################################################
${PKG_NAME} version ${PKG_VERSION}-${PKG_BUILDNUM} has been successfully installed!

This package needs a database wich can be downloaded from http://bit.ly/MAGpurify-db
unzip the database and make it available in the MAGPURIFYDB environmental variable

 " > $PREFIX/.messages.txt

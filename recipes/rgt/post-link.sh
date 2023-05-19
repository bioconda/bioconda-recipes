#!/usr/bin/env bash

cat <<EOF >> ${PREFIX}/.messages.txt

Please run download-db.sh to download all required RGT database files to ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/db/

EOF

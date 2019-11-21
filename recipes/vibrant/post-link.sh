#!/usr/bin/env bash

cat <<EOF >> ${PREFIX}/.messages.txt

Please run download-db.sh to download all required VIBRANT database files to ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/databases/

EOF

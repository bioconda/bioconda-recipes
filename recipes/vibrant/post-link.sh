#!/usr/bin/env bash

cat <<EOF >> ${PREFIX}/.messages.txt

Please run 'download-db.sh' to download all required VIBRANT database files to '${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/db/'.
If you want to download the database files in a different location, please run 'download-db.sh /absolute/path/to/store/databases/' and set 'export VIBRANT_DATA_PATH=/absolute/path/to/store/databases/' before you run VIBRANT.

EOF

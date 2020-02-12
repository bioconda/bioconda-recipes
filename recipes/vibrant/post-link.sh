#!/usr/bin/env bash

cat <<EOF >> ${PREFIX}/.messages.txt

Please run 'download-db.sh path/to/store/databases' to download all required VIBRANT database files.
The path will stored in the environmental variable VIBRANT_DATA_PATH so you don't have to think about
Default location is ${VIBRANT_DATA_PATH}

EOF

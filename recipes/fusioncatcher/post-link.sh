#!/usr/bin/env bash

cat <<EOF >> ${PREFIX}/.messages.txt

Please run download-human-db.sh to download the Human Ensembl database to ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/db/current/.
If you have a custom database, please use "fusioncatcher" with the option "--data".

EOF

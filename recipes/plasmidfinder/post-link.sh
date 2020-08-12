#!/usr/bin/env bash

echo "
Please run download-db.sh to download the PlasmidFinder database to ${PLASMID_DB}.
If you have a database in custom path, please use "plasmidfinder.py" with the option "-p".
" >> ${PREFIX}/.messages.txt
printf '%s\n' "${URLS[@]}" >> "${PREFIX}/.messages.txt" 2>&1

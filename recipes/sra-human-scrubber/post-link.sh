#!/usr/bin/env bash

echo "
Please run 'init_db.sh' to download the database required to run sra-human-scrubber. 
These files will be downloaded to ${SCRUBBER_SHARE}/data. 
" >> ${PREFIX}/.messages.txt
printf '%s\n' "${URLS[@]}" >> "${PREFIX}/.messages.txt" 2>&1

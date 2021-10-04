#!/usr/bin/env bash

echo "
Please run 'download-spatypes.sh' to download the files required to run spaTyper. These files will be downloaded to
${SPATYPER_SHARE} by defualt, unless a path is given (e.g. download-spatypes.sh ./). Please use the '-d' parameter
in spaTyper to change the location of database files.
" >> ${PREFIX}/.messages.txt
printf '%s\n' "${URLS[@]}" >> "${PREFIX}/.messages.txt" 2>&1

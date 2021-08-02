#!/usr/bin/env bash

echo "
Please run update-serotypefinder-db to update the SerotypeFinder database to ${SEROTYPEFINDER_DB}.
If you have a database in custom path, please use "serotypefinder.py" with the option "-p".
" >> ${PREFIX}/.messages.txt
printf '%s\n' "${URLS[@]}" >> "${PREFIX}/.messages.txt" 2>&1

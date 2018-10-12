#!/usr/bin/env bash

echo "Downloading GTDB-Tk database to ${GTDBTK_DB_PATH}..."

# GTDBTK_DB_PATH is defined in build.sh, store the db there
wget https://data.ace.uq.edu.au/public/gtdbtk/release_86/gtdbtk_r86_data.tar.gz -P ${GTDBTK_DB_PATH}
tar xvzf ${GTDBTK_DB_PATH}/gtdbtk_r86_data.tar.gz -C ${GTDBTK_DB_PATH} --strip 1
rm ${GTDBTK_DB_PATH}/gtdbtk_r86_data.tar.gz

echo "GTDB-Tk database is downloaded."

exit 0

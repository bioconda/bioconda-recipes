#!/usr/bin/env bash

echo "Downloading GTDB-Tk database to ${GTDBTK_DATA_PATH}..."

# GTDBTK_DB_PATH is defined in build.sh, store the db there
wget https://data.ace.uq.edu.au/public/gtdbtk/release_86/gtdbtk.r86_v2_data.tar.gz -P ${GTDBTK_DATA_PATH}
tar xvzf ${GTDBTK_DATA_PATH}/gtdbtk.r86_v2_data.tar.gz -C ${GTDBTK_DATA_PATH} --strip 1
rm ${GTDBTK_DATA_PATH}/gtdbtk.r86_v2_data.tar.gz

echo "GTDB-Tk database is downloaded."

exit 0

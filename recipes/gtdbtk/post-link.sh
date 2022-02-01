#!/usr/bin/env bash

echo "
     GTDB-Tk v${PKG_VERSION} requires ~40G of external data which needs to be downloaded
     and unarchived. This can be done automatically, or manually:

     1. Run the command download-db.sh to automatically download to:
        ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/db/

     2. Manually download the latest reference data:
        https://github.com/Ecogenomics/GTDBTk#gtdb-tk-reference-data

     2b. Set the GTDBTK_DATA_PATH environment variable in the file:
         ${PREFIX}/etc/conda/activate.d

" > "${PREFIX}"/.messages.txt

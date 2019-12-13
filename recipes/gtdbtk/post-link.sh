#!/bin/bash

MSGS=$PREFIX/.messages.txt
touch $MSGS

function msg {
    echo $1 >> $MSGS 2>&1
}

msg
msg "GTDB-Tk v${PKG_VERSION} requires ~25G of external data which needs to be downloaded"
msg "and unarchived. This can be done automatically, or manually:"
msg "1. Run the command download-db.sh to automatically download to:"
msg "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/db/"
msg "2. Manually download the latest reference data:"
msg "https://github.com/Ecogenomics/GTDBTk#gtdb-tk-reference-data"
msg "2b. Set the GTDBTK_DATA_PATH environment variable in the file:"
msg "${PREFIX}/etc/conda/activate.d"

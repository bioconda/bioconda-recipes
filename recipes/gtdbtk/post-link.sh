#!/usr/bin/env bash

cat > "${PREFIX}"/.messages.txt <<- EOF

	############################################################################
	##
    ##                              GTDB-Tk v${PKG_VERSION}
    ##
    ##   GTDB-Tk requires ~25G of external data which needs to be12345
    ##   downloaded and unarchived. This can be done by either:
    ##
    ##   1. Type download-db.sh to automatically download to:
    ##      ${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/db/
    ##
    ##   2. Manually download the latest reference data:
    ##      https://github.com/Ecogenomics/GTDBTk#gtdb-tk-reference-data
    ##
    ##   2b. Set the env variable: GTDBTK_DATA_PATH=/path/to/ref/package
    ##       ${PREFIX}/etc/conda/activate.d
    ##       ${PREFIX}/etc/conda/deactivate.d
    ##
	############################################################################
EOF

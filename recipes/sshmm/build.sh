#!/bin/bash

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
echo "export DATAPATH='${PREFIX}/share/rnastructure/data_tables/'" > "${PREFIX}/etc/conda/activate.d/sshmm-env_vars.sh"
echo 'unset DATAPATH' > "${PREFIX}/etc/conda/deactivate.d/sshmm-env_vars.sh"

"${PYTHON}" -m pip install . --no-deps -vv

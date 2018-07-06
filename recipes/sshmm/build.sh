#!/bin/bash

mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d
echo -e '#!/bin/sh\n\nexport DATAPATH='$PREFIX'/share/rnastructure/data_tables/' > $PREFIX/etc/conda/activate.d/env_vars.sh
echo -e '#!/bin/sh\n\nunset DATAPATH' > $PREFIX/etc/conda/deactivate.d/env_vars.sh

pip install sshmm

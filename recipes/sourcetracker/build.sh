#!/bin/bash

cp -r sourcetracker_for_qiime.r src "$CONDA_PREFIX/bin"
mkdir -p $PREFIX/etc/conda/activate.d/
echo '#!/bin/bash
export SOURCETRACKER_PATH="$CONDA_PREFIX/bin"
' > ${PREFIX}/etc/conda/activate.d/sourcetracker_env.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo '#!/bin/bash
unset SOURCETRACKER_PATH
' > ${PREFIX}/etc/conda/deactivate.d/sourcetracker_env.sh

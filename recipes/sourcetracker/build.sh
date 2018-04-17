#!/bin/bash

chmod +x *.r src/*.r
cp -r sourcetracker_for_qiime.r src "$PREFIX/bin"

mkdir -p $PREFIX/etc/conda/activate.d/
echo '#!/bin/bash
export SOURCETRACKER_PATH="$CONDA_PREFIX/bin"
' > ${PREFIX}/etc/conda/activate.d/activate_sourcetracker_env.sh
chmod +x ${PREFIX}/etc/conda/activate.d/activate_sourcetracker_env.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo '#!/bin/bash
unset SOURCETRACKER_PATH
' > ${PREFIX}/etc/conda/deactivate.d/deactivate_sourcetracker_env.sh
chmod +x ${PREFIX}/etc/conda/deactivate.d/deactivate_sourcetracker_env.sh

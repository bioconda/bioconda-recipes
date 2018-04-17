#!/bin/bash

chmod +x *.r src/*.r
cp -r sourcetracker_for_qiime.r src "${PREFIX}/bin"

mkdir -p ${PREFIX}/etc/conda/activate.d/
cat <<EOF > ${PREFIX}/etc/conda/activate.d/activate_sourcetracker_env.sh
#!/bin/bash
export SOURCETRACKER_PATH="${CONDA_PREFIX}/bin"
EOF
chmod +x ${PREFIX}/etc/conda/activate.d/activate_sourcetracker_env.sh

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
cat <<EOF > ${PREFIX}/etc/conda/deactivate.d/deactivate_sourcetracker_env.sh
#!/bin/bash
unset SOURCETRACKER_PATH
EOF
chmod +x ${PREFIX}/etc/conda/deactivate.d/deactivate_sourcetracker_env.sh

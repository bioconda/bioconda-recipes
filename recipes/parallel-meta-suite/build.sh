#!/bin/bash
mkdir -p ${PREFIX}/bin

make CC=$CXX 

cp -r bin/* ${PREFIX}/bin

# # path for database and example
ParallelMETA_path=${PREFIX}/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${ParallelMETA_path}

# set VIBRANT DB PATH variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/pms.sh
export ParallelMETA=${ParallelMETA_path}
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/pms.sh
unset ParallelMETA
EOF

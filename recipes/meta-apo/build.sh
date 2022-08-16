#!/bin/bash
mkdir -p ${PREFIX}/bin

make CC=$CXX

cp -r bin/* ${PREFIX}/bin

# path for meta-apo database and example
MetaApo_path=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}
mkdir -p ${MetaApo_path}
# conda will do the downloading and unpacking, I need do the file moving
mv databases/ ${MetaApo_path}
mv examples/ ${MetaApo_path}

# set VIBRANT DB PATH variable on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/meta-apo.sh
export MetaApo=${MetaApo_path}
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/meta-apo.sh
unset MetaApo
EOF

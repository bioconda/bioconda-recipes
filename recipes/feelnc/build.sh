#!/bin/bash

mkdir -p ${PREFIX}/utils
mkdir -p ${PREFIX}/scripts
mkdir -p ${PREFIX}/lib

cp utils/* ${PREFIX}/utils/
cp scripts/* ${PREFIX}/scripts/
cp -r lib/* ${PREFIX}/lib/

sed -i.bak 's/#!\/usr\/bin\/perl -w/#!\/usr\/bin\/env perl/' ${PREFIX}/scripts/*

# create env file to export all environment variable needed by feelnc scripts
mkdir -p ${PREFIX}/etc/conda/activate.d/

cat <<EOF >> ${PREFIX}/etc/conda/activate.d/feelnc-env.sh
export FEELNCPATH=${PREFIX}/
export PERL5LIB=$PERL5LIB:${PREFIX}/lib/
export PATH=$PATH:${PREFIX}/scripts/:${PREFIX}/utils/
EOF

mkdir -p ${PREFIX}/etc/conda/deactivate.d/
cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/unset-feelnc-env.sh
unset FEELNCPATH
EOF

chmod a+x ${PREFIX}/etc/conda/activate.d/feelnc-env.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/unset-feelnc-env.sh

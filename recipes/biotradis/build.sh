#!/bin/sh
set -x -e
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

cp -r bin/* $PREFIX/bin
cp -r lib/* $PREFIX/lib

mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d

cat <<EOF >> ${PREFIX}/etc/conda/activate.d/env_vars.sh
export PERL5LIB=\$PERL5LIB:\$PREFIX/lib
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/env_vars.sh
unset PERL5LIB
EOF

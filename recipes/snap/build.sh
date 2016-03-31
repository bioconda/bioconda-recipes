#!/bin/sh
make
mkdir -p $PREFIX/bin
mkdir -p ${PREFIX}/share/snap
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cp -p snap fathom forge hmm-info exonpairs cds-trainer.pl hmm-assembler.pl noncoding-trainer.pl patch-hmm.pl zff2gff3.pl $PREFIX/bin
cp -pr HMM ${PREFIX}/share/snap
cp -pr DNA ${PREFIX}/share/snap

# set environment variables using conda's environment activate/deactivate
cat <<EOF >>  ${PREFIX}/etc/conda/activate.d/snapenv.sh
ZOE=\$CONDA_ENV_PATH/share/snap
export ZOE
EOF

cat <<EOF >>  ${PREFIX}/etc/conda/deactivate.d/snapenv.sh
unset ZOE
EOF

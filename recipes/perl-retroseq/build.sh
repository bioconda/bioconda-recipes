#!/bin/bash
set -x -e

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

cp -r ./RetroSeq $PREFIX/lib
cp ./bin/retroseq.pl $PREFIX/bin/retroseq.pl

mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d

echo "export PERL5LIB=$PERL5LIB:$PREFIX/lib" > ${PREFIX}/etc/conda/activate.d/retroseq-perl5lib.sh
chmod a+x ${PREFIX}/etc/conda/activate.d/retroseq-perl5lib.sh

echo "unset PERL5LIB" > ${PREFIX}/etc/conda/deactivate.d/retroseq-perl5lib.sh
chmod a+x ${PREFIX}/etc/conda/deactivate.d/retroseq-perl5lib.sh
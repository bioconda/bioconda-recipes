#!/bin/bash

set -eux -o pipefail

rm -f DWGSIMSrc/samtools/bcftools/*.[oa]
bash make.sh

mkdir -p $PREFIX/share/lrsim
for LRSIM_PROG in simulateLinkedReads.pl dwgsim SURVIVOR msort extractReads samtools faFilter.pl
do
    cp ${LRSIM_PROG} $PREFIX/share/lrsim/
    chmod u+x $PREFIX/share/lrsim/${LRSIM_PROG}
done
cp 4M-with-alts-february-2016.txt $PREFIX/share/lrsim/
#cp simulateLinkedReads.pl_*.so $PREFIX/share/lrsim/
#cp simulateLinkedReads.pl_*.inl $PREFIX/share/lrsim/

mkdir -p $PREFIX/share/lrsim/_Inline
export PERL_INLINE_DIRECTORY=$PREFIX/share/lrsim/_Inline

mkdir -p $PREFIX/bin 
echo "#! /usr/bin/env bash" >> $PREFIX/bin/lrsim
echo "set -eux -o pipefail" >> $PREFIX/bin/lrsim
echo "export PERL_INLINE_DIRECTORY=$PREFIX/share/lrsim/_Inline"
echo "perl $PREFIX/share/lrsim/simulateLinkedReads.pl \"\$@\"" >> $PREFIX/bin/lrsim
chmod +x $PREFIX/bin/lrsim

cat $PREFIX/bin/lrsim
./lrsim || true

pushd test
bash -x test.sh
popd
find . -name '*.inl' || true
find . -name '*.so' || true
find $PREFIX -name '*.inl' || true
find $PREFIX -name '*.so' || true

chmod -R u+w $PREFIX/share/lrsim/_Inline
bash -x clean.sh

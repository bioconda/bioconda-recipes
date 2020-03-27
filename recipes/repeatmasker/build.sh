#!/bin/bash

perl ./configure -trf_prgm ${PREFIX}/bin/trf  -rmblast_dir ${PREFIX}/bin/ -hmmer_dir ${PREFIX}/bin -abblast_dir ${PREFIX}/bin -crossmatch_dir ${PREFIX}/bin

RM_DIR=${PREFIX}/share/RepeatMasker
mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}


# ----- add tools within the bin ------

# add RepeatMasker
ln -s ${RM_DIR}/RepeatMasker

# add other tools
RM_OTHER_PROGRAMS="DateRepeats DupMasker ProcessRepeats RepeatProteinMask"
for name in ${RM_OTHER_PROGRAMS} ; do
  ln -s ${RM_DIR}/${name}
done

# add all utils
for name in ${RM_DIR}/util/* ; do
  ln -s $name
done

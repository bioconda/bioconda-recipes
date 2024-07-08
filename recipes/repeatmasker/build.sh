#!/bin/bash

RM_DIR=${PREFIX}/share/RepeatMasker
mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# configure
cd ${RM_DIR}
perl ./configure -libdir ${RM_DIR}/Libraries -trf_prgm ${PREFIX}/bin/trf  -rmblast_dir ${PREFIX}/bin/ -hmmer_dir ${PREFIX}/bin -abblast_dir ${PREFIX}/bin -crossmatch_dir ${PREFIX}/bin -default_search_engine rmblast

# Delete huge Dfam file, will be downloaded by post-link.sh
# Do it now only, because configure needs the full version
echo "Placeholder file, should be replaced on Conda package installation." > ${RM_DIR}/Libraries/Dfam.h5

# ----- add tools within the bin ------

# add RepeatMasker
ln -s ${RM_DIR}/RepeatMasker ${PREFIX}/bin/RepeatMasker

# add other tools
RM_OTHER_PROGRAMS="DupMasker ProcessRepeats RepeatProteinMask"
for name in ${RM_OTHER_PROGRAMS} ; do
  ln -s ${RM_DIR}/${name} ${PREFIX}/bin/${name}
done

# add all utils
for name in ${RM_DIR}/util/* ; do
  ln -s $name ${PREFIX}/bin/$(basename $name)
done

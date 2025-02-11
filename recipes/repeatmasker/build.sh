#!/bin/bash

RM_DIR="${PREFIX}/share/RepeatMasker"
mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
mv * ${RM_DIR}

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# configure
cd ${RM_DIR}
perl ./configure -libdir "${RM_DIR}/Libraries" -trf_prgm "${PREFIX}/bin/trf" \
	-rmblast_dir "${PREFIX}/bin" -hmmer_dir "${PREFIX}/bin" \
	-abblast_dir "${PREFIX}/bin" -crossmatch_dir "${PREFIX}/bin" \
	-default_search_engine rmblast

# Delete huge Dfam file, will be downloaded by post-link.sh
# Do it now only, because configure needs the full version
echo "Placeholder file, should be replaced on Conda package installation." > ${RM_DIR}/Libraries/Dfam.h5

# ----- add tools within the bin ------

# add RepeatMasker
chmod 0755 ${RM_DIR}/RepeatMasker ${RM_DIR}/DupMasker ${RM_DIR}/ProcessRepeats ${RM_DIR}/RepeatProteinMask
ln -sf ${RM_DIR}/RepeatMasker ${PREFIX}/bin/RepeatMasker

# add other tools
RM_OTHER_PROGRAMS="DupMasker ProcessRepeats RepeatProteinMask"
for name in ${RM_OTHER_PROGRAMS} ; do
  ln -sf ${RM_DIR}/${name} ${PREFIX}/bin/${name}
done

# add all utils
for name in ${RM_DIR}/util/* ; do
  ln -sf $name ${PREFIX}/bin/$(basename $name)
done

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${RM_DIR}/RepeatMasker
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${RM_DIR}/DupMasker
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${RM_DIR}/ProcessRepeats
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${RM_DIR}/RepeatProteinMask
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${RM_DIR}/util/*.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${RM_DIR}/*.pm
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${RM_DIR}/*.pl

rm -rf ${RM_DIR}/util/*.bak
rm -rf ${RM_DIR}/*.bak

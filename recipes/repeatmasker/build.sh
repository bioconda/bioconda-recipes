#!/bin/sh

RM_DIR=${PREFIX}/share/RepeatMasker
mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}

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

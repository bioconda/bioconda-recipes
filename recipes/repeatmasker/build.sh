RM_DIR=${PREFIX}/share/RepeatMasker
RM_OTHER_PROGRAMS="DateRepeats ProcessRepeats RepeatProteinMask DupMasker util/queryRepeatDatabase.pl util/queryTaxonomyDatabase.pl util/rmOutToGFF3.pl util/rmToUCSCTables.pl util/buildRMLibFromEMBL.pl"
RM_PROGRAMS="RepeatMasker $RM_OTHER_PROGRAMS"

mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}
for name in ${RM_PROGRAMS} ; do 
  sed -i 's$^#!.*perl.*$#!/usr/bin/env perl$g;' ${RM_DIR}/${name}
done

cp ${RECIPE_DIR}/RepeatMaskerConfig.pm ${RM_DIR}/RepeatMaskerConfig.pm
# pvanheus - disabled this because the library included with RepeatMasker is too old to be usable
# users will have to provide their own library and point to it using the REPEATMASKER_LIB_DIR environment variable


${RM_DIR}/util/buildRMLibFromEMBL.pl ${RM_DIR}/Libraries/RepeatMaskerLib.embl > ${RM_DIR}/Libraries/RepeatMasker.lib 2>/dev/null
makeblastdb -dbtype nucl -in ${RM_DIR}/Libraries/RepeatMasker.lib
makeblastdb -dbtype prot -in ${RM_DIR}/Libraries/RepeatPeps.lib


cat <<END >>${PREFIX}/bin/RepeatMasker
#!/bin/bash

REPEATMASKER_DIR=\${REPEATMASKER_DIR:-\${CONDA_PREFIX}/share/RepeatMasker}
REPEATMASKER_MATRICES_DIR=\${REPEATMASKED_MATRICES_DIR:-\${CONDA_PREFIX}/share/RepeatMasker/Matrices}
REPEATMASKER_LIB_DIR=\${REPEATMASKER_LIB_DIR:-\${CONDA_PREFIX}/share/RepeatMasker/Libraries}
TRF_DIR=${PREFIX}/bin
RMBLAST_DIR=${PREFIX}/bin
HMMER_DIR=${PREFIX}/bin
export REPEATMASKER_DIR REPEATMASKER_LIB_DIR REPEATMASKER_MATRICES_DIR TRF_DIR RMBLAST_DIR HMMER_DIR

NAME=\$(basename \$0)

perl ${RM_DIR}/\${NAME} \$@
END

chmod a+x ${PREFIX}/bin/RepeatMasker
for name in ${RM_OTHER_PROGRAMS} ; do
  ln -s ${PREFIX}/bin/RepeatMasker ${PREFIX}/bin/$(basename $name)
done

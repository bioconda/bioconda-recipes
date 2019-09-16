#!/bin/bash

RM_DIR=${PREFIX}/share/RepeatMasker
RM_OTHER_PROGRAMS="DateRepeats DupMasker ProcessRepeats RepeatProteinMask util/queryRepeatDatabase.pl util/queryTaxonomyDatabase.pl util/rmOutToGFF3.pl util/calcDivergenceFromAlign.pl util/createRepeatLandscape.pl util/dupliconToSVG.pl util/getRepeatMaskerBatch.pl util/rmOut2Fasta.pl util/trfMask util/rmToUCSCTables.pl util/buildSummary.pl"
RM_PROGRAMS="RepeatMasker $RM_OTHER_PROGRAMS"

mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}
for name in ${RM_PROGRAMS} ; do
  # sed -i 's$^#!.*perl.*$#!/usr/bin/env perl$g;' ${RM_DIR}/${name}
  LC_ALL=C sed -i'' -e 's/^#!.*perl.*$/#!\/usr\/bin\/env perl/g' ${RM_DIR}/${name}
done

cp ${RECIPE_DIR}/RepeatMaskerConfig.pm ${RM_DIR}/RepeatMaskerConfig.pm
# pvanheus - disabled this because the library included with RepeatMasker is too old to be usable
# users will have to provide their own library and point to it using the REPEATMASKER_LIB_DIR environment variable


#${RM_DIR}/util/buildRMLibFromEMBL.pl ${RM_DIR}/Libraries/RepeatMaskerLib.embl > ${RM_DIR}/Libraries/RepeatMasker.lib 2>/dev/null
#makeblastdb -dbtype nucl -in ${RM_DIR}/Libraries/RepeatMasker.lib
#makeblastdb -dbtype prot -in ${RM_DIR}/Libraries/RepeatPeps.lib



cat <<END >>${PREFIX}/bin/RepeatMasker
#!/bin/bash

BINDIR=\$(dirname \$(which RepeatMasker))
BASEDIR=\${BINDIR%/bin}
REPEATMASKER_DIR=\${REPEATMASKER_DIR:-\${BASEDIR}/share/RepeatMasker}
if [[ -z "\$REPEATMASKER_MATRICES_DIR" || "\$REPEATMASKER_MATRICES_DIR" == "NULL" ]] ; then
  REPEATMASKER_MATRICES_DIR=\${BASEDIR}/share/RepeatMasker/Matrices
fi
if [[ -z "\$REPEATMASKER_LIB_DIR" || "\$REPEATMASKER_LIB_DIR" == "NULL" ]] ; then
  REPEATMASKER_LIB_DIR=\${BASEDIR}/share/RepeatMasker/Libraries
fi

if [[ -n "\$REPEATMASKER_REPBASE_FILE" && "\$REPEATMASKER_REPBASE_FILE" != "NULL" ]] ; then
  if [[ ! -f \$REPEATMASKER_REPBASE_FILE || ! -d \$REPEATMASKER_LIB_DIR || ! -w \$REPEATMASKER_LIB_DIR ]] ; then
    echo "If REPEATMASKER_REPBASE_FILE environment variable is specified it must point to a file and the library dir (\$REPEATMASKER_LIB_DIR) must be a writeable directory" >&2
    exit 1
  fi
  cp \$REPEATMASKER_REPBASE_FILE \$REPEATMASKER_LIB_DIR
fi

TRF_DIR=${PREFIX}/bin
RMBLAST_DIR=${PREFIX}/bin
HMMER_DIR=${PREFIX}/bin
export REPEATMASKER_DIR REPEATMASKER_LIB_DIR REPEATMASKER_MATRICES_DIR TRF_DIR RMBLAST_DIR HMMER_DIR REPEATMASKER_CACHE_DIR

NAME=\$(basename \$0)

perl ${RM_DIR}/\${NAME} \$@
END

chmod a+x ${PREFIX}/bin/RepeatMasker
for name in ${RM_OTHER_PROGRAMS} ; do
  ln -s ${PREFIX}/bin/RepeatMasker ${PREFIX}/bin/$(basename $name)
done

if [ -f ${RM_DIR}/conda_build.sh ] ; then
  rm ${RM_DIR}/conda_build.sh
fi

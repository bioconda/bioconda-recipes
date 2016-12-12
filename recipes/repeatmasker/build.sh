RM_DIR=${PREFIX}/share/RepeatMasker
RM_OTHER_PROGRAMS="DateRepeats ProcessRepeats RepeatProteinMask DupMasker util/queryRepeatDatabase.pl util/queryTaxonomyDatabase.pl util/rmOutToGFF3.pl util/rmToUCSCTables.pl"
RM_PROGRAMS="RepeatMasker $RM_OTHER_PROGRAMS"

mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}
for name in ${RM_PROGRAMS} ; do 
  perl -i -0pe 's/^#\\!.*perl.*/#\\!\/usr\/bin\/perl/g;' ${RM_DIR}/${name}
done

cp ${RECIPE_DIR}/RepeatMaskerConfig.pm ${RM_DIR}/RepeatMaskerConfig.pm
${RM_DIR}/util/buildRMLibFromEMBL.pl ${RM_DIR}/Libraries/RepeatMaskerLib.embl > ${RM_DIR}/Libraries/RepeatMasker.lib 2>/dev/null
makeblastdb -dbtype nucl -in ${RM_DIR}/Libraries/RepeatMasker.lib
makeblastdb -dbtype prot -in ${RM_DIR}/Libraries/RepeatPeps.lib

cat <<END >>${PREFIX}/bin/RepeatMasker
#!/bin/bash

REPEATMASKER_DIR=${PREFIX}/share/RepeatMasker
TRF_DIR=${PREFIX}/bin
RMBLAST_DIR=${PREFIX}/bin
HMMER_DIR=${PREFIX}/bin
export REPEATMASKER_DIR TRF_DIR RMBLAST_DIR HMMER_DIR

NAME=\$(basename \$0)

perl ${RM_DIR}/\${NAME} \$@
END

chmod a+x ${PREFIX}/bin/RepeatMasker
for name in ${RM_OTHER_PROGRAMS} ; do
  ln -s ${PREFIX}/bin/RepeatMasker ${PREFIX}/bin/$(basename $name)
done

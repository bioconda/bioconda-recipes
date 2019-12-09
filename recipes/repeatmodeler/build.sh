#!/bin/sh
set -x -e

RM_DIR=${PREFIX}/share/RepeatModeler
RM_OTHER_PROGRAMS="BuildDatabase Refiner RepeatClassifier TRFMask util/Linup util/viewMSA.pl"
RM_PROGRAMS="RepeatModeler $RM_OTHER_PROGRAMS"

# Hack J. Dainat - fix path to access
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' 's/REPEATMODELER_DIR\/Refiner/REFINER_PRGM/'  ${RM_DIR}/RepeatModeler
  sed -i '' 's/REPEATMODELER_DIR\/TRFMask/TRFMASK_PRGM/' ${RM_DIR}/RepeatModeler
  sed -i '' 's/REPEATMODELER_DIR\/RepeatClassifier/REPEATCLASSIFIER_PRGM/' ${RM_DIR}/RepeatModeler
  sed -i '' 's/REPEATMODELER_DIR\/TRFMask/TRFMASK_PRGM/' ${RM_DIR}/RepeatClassifier
else
  sed -i 's/REPEATMODELER_DIR\/Refiner/REFINER_PRGM/' ${RM_DIR}/RepeatModeler
  sed -i 's/REPEATMODELER_DIR\/TRFMask/TRFMASK_PRGM/' ${RM_DIR}/RepeatModeler
  sed -i 's/REPEATMODELER_DIR\/RepeatClassifier/REPEATCLASSIFIER_PRGM/' ${RM_DIR}/RepeatModeler
  sed -i 's/REPEATMODELER_DIR\/TRFMask/TRFMASK_PRGM/' ${RM_DIR}/RepeatClassifier
fi
# END HACK

mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}

# Copy edited config file for auto configuration
cp ${RECIPE_DIR}/RepModelConfig.pm ${RM_DIR}/RepModelConfig.pm

# make DB if missing
if [ -f ${PREFIX}/share/RepeatMasker/Libraries/RepeatPeps.lib ] && [ ! -f ${PREFIX}/share/RepeatMasker/Libraries/RepeatPeps.lib.psq ] ; then
  makeblastdb -dbtype prot -in ${PREFIX}/share/RepeatMasker/Libraries/RepeatPeps.lib
fi

# Set env variables for config parameters needed in RepModelConfig.pm
cat <<END >>${PREFIX}/bin/RepeatModeler
#!/bin/bash
REPEATMODELER_DIR=${PREFIX}/share/RepeatModeler
REPEATMASKER_DIR=${PREFIX}/share/RepeatMasker
TRF_DIR=${PREFIX}/bin
RMBLAST_DIR=${PREFIX}/bin
RECON_DIR=${PREFIX}/bin
RSCOUT_DIR=${PREFIX}/bin
NSEG_DIR=${PREFIX}/bin
export REPEATMODELER_DIR REPEATMASKER_DIR TRF_DIR RMBLAST_DIR RECON_DIR RSCOUT_DIR NSEG_DIR
NAME=\$(basename \$0)
perl ${RM_DIR}/\${NAME} \$@
END

chmod a+x ${PREFIX}/bin/RepeatModeler
for name in ${RM_OTHER_PROGRAMS} ; do
  ln -s ${PREFIX}/bin/RepeatModeler ${PREFIX}/bin/$(basename $name)
done

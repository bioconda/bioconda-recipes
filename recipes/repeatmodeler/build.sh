#!/bin/sh
set -x -e

RM_DIR=${PREFIX}/share/RepeatModeler
RM_OTHER_PROGRAMS="BuildDatabase Refiner RepeatClassifier TRFMask LTRPipeline util/dfamConsensusTool.pl util/renameIds.pl util/Linup util/viewMSA.pl"
RM_PROGRAMS="RepeatModeler $RM_OTHER_PROGRAMS"

mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}

# Hack J. Dainat - fix path to access the tools through the wrapper in the bin otherwise fails 
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' 's/$FindBin::RealBin\/Refiner/Refiner/'  ${RM_DIR}/RepeatModeler
  sed -i '' 's/$FindBin::RealBin\/TRFMask/TRFMask/' ${RM_DIR}/RepeatModeler
  sed -i '' 's/$FindBin::RealBin\/RepeatClassifier/RepeatClassifier/' ${RM_DIR}/RepeatModeler
  sed -i '' 's/$FindBin::RealBin\/LTRPipeline/LTRPipeline/' ${RM_DIR}/RepeatModeler
else
  sed -i 's/$FindBin::RealBin\/Refiner/Refiner/' ${RM_DIR}/RepeatModeler
  sed -i 's/$FindBin::RealBin\/TRFMask/TRFMask/' ${RM_DIR}/RepeatModeler
  sed -i 's/$FindBin::RealBin\/LTRPipeline/LTRPipeline/' ${RM_DIR}/RepeatModeler
fi
# END HACK

# Copy edited config file for auto configuration
cp ${RECIPE_DIR}/RepModelConfig.pm ${RM_DIR}/RepModelConfig.pm

# Set env variables for config parameters needed in RepModelConfig.pm
cat <<END >>${PREFIX}/bin/RepeatModeler
#!/bin/bash

REPEATMODELER_DIR=${PREFIX}/share/RepeatModeler
REPEATMASKER_DIR=${PREFIX}/share/RepeatMasker
ABBLAST_DIR=${PREFIX}/bin
CDHIT_DIR=${PREFIX}/bin
GENOMETOOLS_DIR=${PREFIX}/bin
LTR_RETRIEVER_DIR=${PREFIX}/bin
MAFFT_DIR=${PREFIX}/bin
NINJA_DIR=${PREFIX}/bin
RECON_DIR=${PREFIX}/bin
RMBLAST_DIR=${PREFIX}/bin
RSCOUT_DIR=${PREFIX}/bin
TRF_PRGM=${PREFIX}/bin/trf
export REPEATMODELER_DIR REPEATMASKER_DIR ABBLAST_DIR TRFMASK_DIR CDHIT_DIR GENOMETOOLS_DIR LTR_RETRIEVER_DIR MAFFT_DIR NINJA_DIR RECON_DIR RMBLAST_DIR RSCOUT_DIR TRF_PRGM
NAME=\$(basename \$0)
perl ${RM_DIR}/\${NAME} \$@
END

chmod a+x ${PREFIX}/bin/RepeatModeler
for name in ${RM_OTHER_PROGRAMS} ; do
  ln -s ${PREFIX}/bin/RepeatModeler ${PREFIX}/bin/$(basename $name)
done

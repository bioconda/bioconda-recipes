#!/bin/bash

# if ! [ -z "${CONDA_BUILD+x}" ]; then
#    echo "### exec ! if"    
#    find /share/home/zju_hjy/conda-bld/ -name "build_env_setup.sh" -type f -exec ls -t {} +
#    find /share/home/zju_hjy/conda-bld/ -name "build_env_setup.sh" -type f -exec ls -t {} + | head -1
#    sourcefile=$(find /share/home/zju_hjy/conda-bld/ -name "build_env_setup.sh" -type f -exec ls -t {} + | head -1)
#    echo ${sourcefile}
#    source ${sourcefile}
# fi

# echo "###" ${CONDA_BUILD+x}
# echo "SRC_DIR (源码位置_260114): ${SRC_DIR}"
# echo "PREFIX (安装目标260114): ${PREFIX}"

# export PREFIX=/share/home/zju_hjy/conda-bld/hquate_1768380444575/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placeho
# export SRC_DIR=/share/home/zju_hjy/conda-bld/hquate_1768380444575/work


mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/examples

cd $SRC_DIR
echo "Installing executable scripts..."
cp bin/AbnormalERVDetection.sh ${PREFIX}/bin/
cp bin/abnormal_ERVs.py ${PREFIX}/bin/
cp bin/ByJointProbability.sh ${PREFIX}/bin/
cp bin/ByTEAnnotation.sh ${PREFIX}/bin/
cp bin/ByTEConsensus_SubFamily.sh ${PREFIX}/bin/
cp bin/ByTESubfamily.sh ${PREFIX}/bin/
cp bin/ByTETranscript.sh ${PREFIX}/bin/
cp bin/ERVFamily ${PREFIX}/bin/
cp bin/expTEsub_cattle ${PREFIX}/bin/
cp bin/expTEsub_chicken ${PREFIX}/bin/
cp bin/expTEsub_goat ${PREFIX}/bin/
cp bin/expTEsub_pig ${PREFIX}/bin/
cp bin/expTEsub_sheep ${PREFIX}/bin/
cp bin/filterGFF ${PREFIX}/bin/
cp bin/insideConnection.sh ${PREFIX}/bin/
cp bin/LocaTE ${PREFIX}/bin/
# cp bin/locaTE ${PREFIX}/bin/
cp bin/LocaTE ${PREFIX}/bin/locaTE
cp examples/test.bam ${PREFIX}/examples/
cp examples/testTE.gff ${PREFIX}/examples/

chmod +x ${PREFIX}/bin/locaTE
chmod +x ${PREFIX}/bin/LocaTE
chmod +x ${PREFIX}/bin/filterGFF


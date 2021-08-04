#! /usr/bin/env bash
set -e
set -u

# If no model given, print help message
if [ $# -eq 0 ]; then
    echo "usage: download-vadr-models.sh MODEL_NAME"
    echo ""
    echo "MODEL_NAME can be one of the following: sarscov2 caliciviridae coronaviridae cox1 flaviviridae"
    echo ""
    echo "Example: download-vadr-models.sh sarscov2"
    echo ""
    echo "To get an updated list of available models please visit https://ftp.ncbi.nlm.nih.gov/pub/nawrocki/vadr-models/"
    exit 1
fi

# Covert VADR version to Model version (e.g. 1.2.1 -> 1.2-1)
MVERSION=$(echo $VADRVERSION | sed -r 's/([0-9]).([0-9]).([0-9])/\1.\2-\3/')

# Download model
CURRENT_DIR=$(pwd)
mkdir -p ${VADRMODELDIR}/tmp
cd $VADRMODELDIR/tmp
for model in $*; do
    echo "Downloaded VADR model for ${model} to ${VADRMODELDIR}"
    clean_model=${model}
    if [[ "${model}" == *"viridae"* ]]; then
        clean_model=${model%viridae}
    fi

    wget --quiet -O vadr-models-${model}.tar.gz https://ftp.ncbi.nlm.nih.gov/pub/nawrocki/vadr-models/${model}/${MVERSION}/vadr-models-${clean_model}-${MVERSION}.tar.gz
    tar -xzf vadr-models-${model}.tar.gz
    mv vadr-models-${clean_model}-$MVERSION/* ${VADRMODELDIR}/
    rm -rf $VADRMODELDIR/tmp/*
    echo "VADR model for ${model} setup"
done
rm -rf $VADRMODELDIR/tmp/
cd ${CURRENT_DIR}

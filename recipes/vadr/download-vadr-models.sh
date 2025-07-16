#! /usr/bin/env bash
set -e
set -u
MODEL_VERSIONS="${VADRMODELDIR}/MODEL-VERSIONS.txt"

# Download MODEL-VERSIONS.txt from https://github.com/nawrockie/vadr-extra
echo "Downloading current list of available VADR models..."
wget --quiet -O ${MODEL_VERSIONS} https://raw.githubusercontent.com/nawrockie/vadr-extra/master/MODEL-VERSIONS.txt
AVAILABLE_MODELS=$(grep -v "^#" $MODEL_VERSIONS | cut -f 1 | tr '\n' ' ')

# If no model given, print help message
if [ $# -eq 0 ]; then
    echo "usage: download-vadr-models.sh MODEL_NAME"
    echo ""
    echo "Available models: ${AVAILABLE_MODELS}"
    echo ""
    echo "Example: download-vadr-models.sh sarscov2"

    exit 0
fi

# Verify VADR version matches expected
if [[ -z "${BIOCONDA_BUILD+x}" ]]; then
    CURRENT_VERSION=$(v-annotate.pl -h | head -n 2 | tail -n 1)
    EXPECTED_VERSION=$(head -n 1 ${MODEL_VERSIONS})
    if [[ "${CURRENT_VERSION}" != "${EXPECTED_VERSION}" ]]; then
        echo "Installed VADR Version: ${VADRVERSION}"
        echo "Expected VADR Version: ${EXPECTED_VERSION}"
        echo "Please update your install of VADR to use the download script. Otherwise you will need to manually install the models."
        exit 1
    fi
fi

# Download model
CURRENT_DIR=$(pwd)
mkdir -p ${VADRMODELDIR}/tmp
cd $VADRMODELDIR/tmp
for model in $*; do
    MODEL_FOUND="0"
    for vadr_model in $AVAILABLE_MODELS; do
        if [[ "${model}" == "${vadr_model}" ]]; then
            MODEL_FOUND="1"
        fi
    done

    if [[ "${MODEL_FOUND}" == "1" ]]; then
        echo "Downloaded VADR model for ${model} to ${VADRMODELDIR}"
        # #model-set	version	ftp-path	bitbucket-tag
        # calici	1.2-1	https://ftp.ncbi.nlm.nih.gov/pub/nawrocki/vadr-models/caliciviridae/1.2-1/vadr-models-calici-1.2-1.tar.gz	vadr-models-calici-1.2-1
        MVERSION=$(grep "^${model}" ${MODEL_VERSIONS} | cut -f 2)
        MURL=$(grep "^${model}" ${MODEL_VERSIONS} | cut -f 3)
        MPREFIX=$(grep "^${model}" ${MODEL_VERSIONS} | cut -f 4 | tr -d '\n')

        wget --no-verbose -O ${MPREFIX}.tar.gz ${MURL}
        tar -xzf ${MPREFIX}.tar.gz
        mv ${MPREFIX}/00NOTES.txt ${MPREFIX}/${model}-NOTES.txt
        mv ${MPREFIX}/00README.txt ${MPREFIX}/${model}-README.txt
        mv ${MPREFIX}/RELEASE-NOTES.txt ${MPREFIX}/${model}-RELEASE-NOTES.txt
        mv ${MPREFIX}/* ${VADRMODELDIR}/
        rm -rf $VADRMODELDIR/tmp/*
        echo "VADR model for ${model} setup"
    else
        echo "${model} is not an available VADR model, skipping..."
    fi
done
rm -rf $VADRMODELDIR/tmp/
cd ${CURRENT_DIR}

echo "Currently installed VADR models..."
installed-vadr-models.sh

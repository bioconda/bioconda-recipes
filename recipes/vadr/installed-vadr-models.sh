#! /usr/bin/env bash
set -e
set -u
MODEL_VERSIONS="${VADRMODELDIR}/MODEL-VERSIONS.txt"

if [ -f $MODEL_VERSIONS ]; then
    AVAILABLE_MODELS=$(grep -v "^#" $MODEL_VERSIONS | cut -f 1 | tr '\n' ' ')
    for vadr_model in $AVAILABLE_MODELS; do
        MODEL_FILE="${VADRMODELDIR}/${vadr_model}-README.txt"
        if [ -f $MODEL_FILE ]; then
            MDATE=$(head -n 1 ${MODEL_FILE} | tr -d '\n')
            MVERSION=$(head -n 2 ${MODEL_FILE} | tail -n 1 | tr -d '\n')
            echo "${vadr_model}#${MVERSION}#${MDATE}" | sed 's/#/\t/g'
        fi
    done
else
    echo "No VADR models found."
fi

#!/usr/bin/env bash

if [ -z "$2" ]; then
    OUTPUT_PATH="."
else
    OUTPUT_PATH=$2
fi

if [ "$1" == "-Regular" ]; then
    cp $CONDA_PREFIX/configTemplates/SiprosEnsembleConfig.cfg $OUTPUT_PATH
elif [ "$1" == "-SIP" ]; then
    cp $CONDA_PREFIX/configTemplates/SiprosV4Config.cfg $OUTPUT_PATH
else
    echo "Usage: copyConfigTemplate {-Regular|-SIP} <output_path>"
    exit 1
fi
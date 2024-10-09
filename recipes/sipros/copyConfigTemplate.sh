#!/usr/bin/env bash

if [ -z "$2" ]; then
    OUTPUT_PATH="."
else
    OUTPUT_PATH=$2
fi

if [ -z "$CONDA_PREFIX" ]; then
    echo "Error: CONDA_PREFIX is not set. Are you running this in a Conda environment?"
    exit 1
fi

TEMPLATE_DIR="$CONDA_PREFIX/configTemplates"

if [ "$1" == "-Regular" ]; then
    TEMPLATE="$TEMPLATE_DIR/SiprosEnsembleConfig.cfg"
elif [ "$1" == "-SIP" ]; then
    TEMPLATE="$TEMPLATE_DIR/SiprosV4Config.cfg"
else
    echo "Usage: copyConfigTemplate {-Regular|-SIP} <output_path>"
    exit 1
fi

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: Template file $TEMPLATE not found"
    exit 1
fi

cp -v "$TEMPLATE" "$OUTPUT_PATH"
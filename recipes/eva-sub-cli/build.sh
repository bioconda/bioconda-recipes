#!/bin/bash

BIOVALIDATOR_VERSION=2.2.1

EVA_SUB_CLI="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${EVA_SUB_CLI}

# Install eva-sub-cli
$PYTHON -m pip install .
echo "Done with eva-sub-cli"

cd ${EVA_SUB_CLI}

# Install biovalidator from source
curl -Lo biovalidator.zip https://github.com/elixir-europe/biovalidator/archive/refs/tags/v${BIOVALIDATOR_VERSION}.zip \
    && unzip -q biovalidator.zip && rm biovalidator.zip \
    && cd biovalidator-${BIOVALIDATOR_VERSION} \
    && npm install && npm install -g \
    && cd ..
echo "Done with biovalidator"

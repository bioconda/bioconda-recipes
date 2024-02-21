#!/bin/bash

VCF_VALIDATOR_VERSION=0.9.6
BIOVALIDATOR_VERSION=2.1.0
EVA_PYUTILS_VERSION=0.6.1

EVA_SUB_CLI="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${PREFIX}/bin ${EVA_SUB_CLI}

# Install eva-sub-cli
$PYTHON -m pip install .
cp bin/* ${PREFIX}/bin
echo "Done with eva-sub-cli"

cd ${EVA_SUB_CLI}

# Install python dependencies not yet on conda
curl -Lo eva-pyutils.zip https://github.com/EBIvariation/eva-common-pyutils/archive/refs/tags/v${EVA_PYUTILS_VERSION}.zip \
    && unzip eva-pyutils.zip && rm eva-pyutils.zip \
    && cd eva-common-pyutils-${EVA_PYUTILS_VERSION} \
    && $PYTHON setup.py install \
    && cd ..

# Install biovalidator from source
# Includes some workarounds that can be cleaned up once a new version is released
curl -Lo biovalidator.zip https://github.com/elixir-europe/biovalidator/archive/refs/tags/v${BIOVALIDATOR_VERSION}.zip \
    && unzip biovalidator.zip && rm biovalidator.zip \
    && cd biovalidator-${BIOVALIDATOR_VERSION} \
    && bash -c "cat <(echo '#!/usr/bin/env node') <(cat src/biovalidator.js) > tmp" \
    && mv tmp src/biovalidator.js \
    && chmod +x src/biovalidator.js \
    && sed -i 's/dist/src/' package.json \
    && npm install && npm install -g \
    && cd ..
echo "Done with biovalidator"

# Download pre-built vcf-validator
# Check if linux or osx
if [ -z ${OSX_ARCH+x} ]; then
  curl -LJo ${PREFIX}/bin/vcf_validator  https://github.com/EBIvariation/vcf-validator/releases/download/v${VCF_VALIDATOR_VERSION}/vcf_validator_linux \
    && curl -LJo ${PREFIX}/bin/vcf_assembly_checker  https://github.com/EBIvariation/vcf-validator/releases/download/v${VCF_VALIDATOR_VERSION}/vcf_assembly_checker_linux \
    && chmod 755 ${PREFIX}/bin/vcf_assembly_checker ${PREFIX}/bin/vcf_validator
else
  curl -LJo ${PREFIX}/bin/vcf_validator  https://github.com/EBIvariation/vcf-validator/releases/download/v${VCF_VALIDATOR_VERSION}/vcf_validator_macos \
    && curl -LJo ${PREFIX}/bin/vcf_assembly_checker  https://github.com/EBIvariation/vcf-validator/releases/download/v${VCF_VALIDATOR_VERSION}/vcf_assembly_checker_macos \
    && chmod 755 ${PREFIX}/bin/vcf_assembly_checker ${PREFIX}/bin/vcf_validator
fi
echo "Done with vcf-validator"

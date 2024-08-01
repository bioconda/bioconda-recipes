#!/bin/bash
set -ex

# Create and activate eukfinder environment
conda env create -f eukfinder_env.yml

# Install additional dependencies
wget https://github.com/PLAST-software/plast-library/releases/download/v2.3.2/plastbinary_linux_v2.3.2.tar.gz

# Setup PLAST binaries
tar -zxf plastbinary_linux_v2.3.2.tar.gz

# Clone acc2tax repository
git clone https://github.com/richardmleggett/acc2tax.git

# Build acc2tax
cd acc2tax
# According to https://bioconda.github.io/contributor/troubleshooting.html
# and https://github.com/bioconda/bioconda-recipes/pull/49360#discussion_r1686187284
$(which "&CC") -o acc2tax acc2tax.c


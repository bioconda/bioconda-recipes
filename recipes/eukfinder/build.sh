#!/bin/bash
set -ex

pip install .

# Install additional dependencies
wget https://github.com/PLAST-software/plast-library/releases/download/v2.3.2/plastbinary_linux_v2.3.2.tar.gz
echo "PLAST downloaded successfully"

# Setup PLAST binaries
tar -zxf plastbinary_linux_v2.3.2.tar.gz
plastbinary_linux_v2.3.2/plast -h || { echo 'PLAST installation failed'; exit 1; }
echo "PLAST installed successfully"

# Clone acc2tax repository
git clone https://github.com/richardmleggett/acc2tax.git
echo "acc2tax downloaded successfully"

# Build acc2tax
cd acc2tax
# According to https://bioconda.github.io/contributor/troubleshooting.html
# and https://github.com/bioconda/bioconda-recipes/pull/49360#discussion_r1686187284
$(which "$CC") -o acc2tax acc2tax.c
./acc2tax --help || { echo 'acc2tax build failed'; exit 1; }
echo "acc2tax installed successfully"
cd ..

source $(conda info --base)/etc/profile.d/conda.sh

# Check if the eukfinder environment exists, and create it if it doesn't
conda env create -f eukfinder_env.yml
conda activate eukfinder

export PATH=$PREFIX/bin:$PATH

eukfinder read_prep -h
eukfinder short_seqs -h
eukfinder long_seqs -h

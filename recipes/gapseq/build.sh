#!/usr/bin/env bash

# Installation instructions taken from https://github.com/jotech/gapseq/blob/master/docs/install.md#conda 2024-04-23 by cmkobel


# Copy contents to conda prefix
mkdir -p ${PREFIX}/gapseq
cp ISSUE_TEMPLATE.MD LICENSE README.md gapseq* gapseq_env.yml ${PREFIX}/gapseq
cp -r dat/ docs/ src/ toy/ unit/ ${PREFIX}/gapseq


# install one additional R-package
# R -e 'install.packages("CHNOSZ", repos="http://cran.us.r-project.org")' # Is now available on bioconda, simply.

# Install package which was previously removed from cran due to unfixed errors. I (cmkobel) decided to keep this here since it was part of the original conda installation instructions.
wget https://cran.r-project.org/src/contrib/Archive/sybilSBML/sybilSBML_3.1.2.tar.gz
R CMD INSTALL --configure-args=" \
--with-sbml-include=$CONDA_PREFIX/include \
--with-sbml-lib=$CONDA_PREFIX/lib" sybilSBML_3.1.2.tar.gz
rm sybilSBML_3.1.2.tar.gz


# Download reference sequence data
bash ./src/update_sequences.sh

# The test is moved to the test section of meta.yaml
# ./gapseq test

# Final setup

Make binary available
mkdir -p ${PREFIX}/bin
ln -s ${PREFIX}/gapseq/gapseq ${PREFIX}/bin/gapseq


# --- 


# Build at home with (before submitting to azure)
# conda activate bioconda-utils
# bioconda-utils lint --git-range master
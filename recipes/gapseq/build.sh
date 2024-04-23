#!/usr/bin/env bash

# Installation instructions taken from https://github.com/jotech/gapseq/blob/master/docs/install.md#conda 2024-04-23 by cmkobel

# Copy contents to conda prefix
mkdir -p ${PREFIX}/gapseq
cp ISSUE_TEMPLATE.MD LICENSE README.md gapseq gapseq_env.yml ${PREFIX}/gapseq
cp -r dat/ docs/ src/ toy/ unit/ ${PREFIX}/gapseq

# install one additional R-package
# R -e 'install.packages("CHNOSZ", repos="http://cran.us.r-project.org")' # Is now available on bioconda, simply.

# Install package which was previously removed from cran due to unfixed errors. I (cmkobel) decided to keep this here since it was part of the original conda installation instructions.
# Unfortunately it is not possible to installed this archived version of sybilSBML because the newly installed R is necessary to do so, and we don't have access to it at this point.
# This is not possible, as the environment is not activated of course. The user must do this manually afterwards.
# wget https://cran.r-project.org/src/contrib/Archive/sybilSBML/sybilSBML_3.1.2.tar.gz
# R CMD INSTALL --configure-args=" \
# --with-sbml-include=$CONDA_PREFIX/include \
# --with-sbml-lib=$CONDA_PREFIX/lib" sybilSBML_3.1.2.tar.gz
# rm sybilSBML_3.1.2.tar.gz
# There is a workaround to do this which requires setting the correct lib path, but I think it is not strictl necessary to get the package running. Instead we can maybe think of ways to make these easy to install for the user after conda install.

# We must use the installed file as it uses its directory to set the path for the sequence installation.
bash ${PREFIX}/gapseq/src/update_sequences.sh


# Final setup

# Make binary available
mkdir -p ${PREFIX}/bin
ln -s ${PREFIX}/gapseq/gapseq ${PREFIX}/bin/gapseq


# --- 


# Build at home with (before submitting to azure):
# conda activate bioconda-utils
# bioconda-utils lint --git-range master
# bioconda-utils build --mulled-test --git-range master
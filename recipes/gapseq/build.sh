#!/usr/bin/env bash

# Installation instructions taken from https://github.com/jotech/gapseq/blob/master/docs/install.md#conda April 2024 by cmkobel

# Copy contents to conda prefix
mkdir -p ${PREFIX}/gapseq/
cp ISSUE_TEMPLATE.MD LICENSE README.md gapseq gapseq_env.yml ${PREFIX}/gapseq/
cp -r dat/ docs/ src/ toy/ unit/ ${PREFIX}/gapseq/


# Installing the CRAN archived sybilSBML package here requires a bunch of debugging to set the lib paths in R. That time is probably better spend fixing the package (sybilSBML) in the first place. So here is a quick workaround that makes this process a bit easier for the user. SybilSBML is not strictly necessary so I think the priority should be to get the main package (gapseq) working first.
echo '''#!/usr/bin/env bash
wget https://cran.r-project.org/src/contrib/Archive/sybilSBML/sybilSBML_3.1.2.tar.gz
R CMD INSTALL --configure-args=" \
--with-sbml-include=$CONDA_PREFIX/include \
--with-sbml-lib=$CONDA_PREFIX/lib" sybilSBML_3.1.2.tar.gz
rm sybilSBML_3.1.2.tar.gz
''' > ${PREFIX}/gapseq/src/install_archived_sybilSBML.sh
chmod +x ${PREFIX}/gapseq/src/install_archived_sybilSBML.sh
# Now the user can "easily" install this after installing the bioconda package with install_archived_sybilSBML.sh (This file will be linked to bin/).


# Download reference sequence data
# To install the database, we must call the installed file as it uses its own path to place the files correctly.
bash ${PREFIX}/gapseq/src/update_sequences.sh


# Final setup - Make binary available
mkdir -p ${PREFIX}/bin
ln -sr ${PREFIX}/gapseq/gapseq ${PREFIX}/bin/
ln -sr ${PREFIX}/gapseq/src/update_sequences.sh ${PREFIX}/bin/
ln -sr ${PREFIX}/gapseq/src/install_archived_sybilSBML.sh ${PREFIX}/bin/


# --- 


# Build at home with (before submitting to azure):
# conda activate bioconda-utils
# bioconda-utils lint --git-range master
# bioconda-utils build --mulled-test --git-range master

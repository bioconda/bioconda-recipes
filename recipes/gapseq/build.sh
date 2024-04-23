#!/usr/bin/env bash




# Copy contents to conda prefix
cp -r gapseq-{{ version }} $PREFIX



# install one additional R-package
# R -e 'install.packages("CHNOSZ", repos="http://cran.us.r-project.org")' # Is now available on bioconda, simply.

# Install package which was previously removed from cran due to unfixed errors.
wget https://cran.r-project.org/src/contrib/Archive/sybilSBML/sybilSBML_3.1.2.tar.gz
R CMD INSTALL --configure-args=" \
--with-sbml-include=$CONDA_PREFIX/include \
--with-sbml-lib=$CONDA_PREFIX/lib" sybilSBML_3.1.2.tar.gz
rm sybilSBML_3.1.2.tar.gz


# Download reference sequence data
bash ./src/update_sequences.sh


# ---

Make binary available
mkdir -p ${PREFIX}/bin
ln -s ${PREFIX}/gapseq/gapseq ${PREFIX}/bin/gapseq

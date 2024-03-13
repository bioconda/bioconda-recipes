#!/bin/bash

set -e

# Create a Conda environment with specified R dependencies
conda create -n cellhashr_env -c conda-forge r-base>=4.3.2 r-essentials r-devtools r-rcpp r-rcpparmadillo r-rcppeigen r-rcppparallel r-rcppprogress bioconductor-preprocesscore r-pdftools bioconductor-demuxmix r-magick bioconductor-s4vectors bioconductor-dropletutils bioconductor-singlecellexperiment r-biocmanager

# Activate the Conda environment
conda activate cellhashr_env

# Clone the repository and checkout the specified version
git clone https://github.com/BimberLab/cellhashR.git
cd cellhashR
git checkout 1.0.4
# Build and install the package
R CMD build .
R CMD INSTALL cellhashR_1.04.tar.gz

# Run tests
Rscript -e "library('cellhashR')"

# Deactivate Conda environment
conda deactivate

echo "Build process completed successfully."
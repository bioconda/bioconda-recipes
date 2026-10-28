#!/bin/bash
#mkdir -p ~/.R
#echo -e "CC=$CC
#FC=$FC
#CXX=$CXX
#CXX98=$CXX
#CXX11=$CXX
#CXX14=$CXX" > ~/.R/Makevars

# install bioconductor
#echo 'if (!requireNamespace("BiocManager", quietly = TRUE))' > install.r
#echo '    install.packages("BiocManager",repos = "http://cran.us.r-project.org")' >> install.r
#echo 'BiocManager::install(version = "3.12")' >> install.r

# install bioconductor package flowCore
#echo 'BiocManager::install("flowCore")' >> install.r

# actually execute installation
#cat install.r | R --vanilla

# install FlowSoFine
$R CMD INSTALL --build .
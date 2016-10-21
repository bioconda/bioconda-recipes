#!/bin/bash
#conda build . -c bioconda -c conda-forge -c r

$R CMD INSTALL --build .

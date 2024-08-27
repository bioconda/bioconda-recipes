#!/bin/bash

conda config --add channels r
conda config --add channels conda-forge
conda config --add channels bioconda

export DISABLE_AUTOBREW=1
$R CMD INSTALL --build .
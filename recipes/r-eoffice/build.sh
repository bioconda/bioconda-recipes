#!/bin/bash
conda install -c r r-devemf
export DISABLE_AUTOBREW=1
$R CMD INSTALL --build .
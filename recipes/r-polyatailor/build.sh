#!/bin/bash

export DISABLE_AUTOBREW=1
$R install_github("helixcn/seqRFLP")
$R CMD INSTALL --build .
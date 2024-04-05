#!/bin/bash

$R CMD INSTALL --build .

pushd extdata
install "step1_fitNULLGLMM.R" "step2_SPAtests.R" "createSparseGRM.R" "extractNglmm.R" "${PREFIX}/bin"
popd

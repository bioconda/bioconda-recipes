#!/bin/bash
set -eu -o pipefail

# ## Binary install with wrappers

mkdir -p "${PREFIX}/bin"

make all 

mv svm_learn "${PREFIX}/bin/"
mv svm_classify "${PREFIX}/bin/"

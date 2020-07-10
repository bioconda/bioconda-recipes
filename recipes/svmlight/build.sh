#!/bin/bash
set -eu -o pipefail

# ## Binary install with wrappers

mkdir -p "${PREFIX}/bin"

make CC="${CC}" LD="${LD}" CFLAGS="${CFLAGS}" LFLAGS="${LDFLAGS}" all 

mv svm_learn "${PREFIX}/bin/"
mv svm_classify "${PREFIX}/bin/"

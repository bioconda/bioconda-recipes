#!/bin/bash
set -eu -o pipefail

# ## Binary install with wrappers

make CC="${CC}" LD="${CC}" CFLAGS="-fcommon ${CFLAGS}" LFLAGS="${LDFLAGS}" all

mkdir -p "${PREFIX}/bin"

mv svm_learn svm_classify "${PREFIX}/bin/"

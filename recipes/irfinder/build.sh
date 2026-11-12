#!/bin/bash
set -xe

# The upstream makefiles hardcode g++ and miss <cstdint> (fails on modern GCC).
grep -rl 'g++' src/irfinder/Release | xargs sed -i.bak "s#g++#${CXX} ${CXXFLAGS} -include cstdint ${LDFLAGS}#g"
find src/irfinder -name '*.bak' -delete
# 'ulong' is a glibc-only typedef (missing on macOS): provide it via a force-included header.
echo 'typedef unsigned long ulong;' > "${SRC_DIR}/ulong_compat.h"
sed -i.bak "s#-include cstdint#-include cstdint -include ${SRC_DIR}/ulong_compat.h#" src/irfinder/Release/src/*/subdir.mk src/irfinder/Release/src/subdir.mk
find src/irfinder -name '*.bak' -delete

# macOS has no <endian.h> (crc32.cpp expects the glibc one): provide a shim.
if [[ "$(uname)" == "Darwin" ]]; then
    mkdir -p "${SRC_DIR}/compat"
    cat > "${SRC_DIR}/compat/endian.h" <<'SHIM'
#pragma once
#include <machine/endian.h>
#ifndef __BYTE_ORDER
#define __BYTE_ORDER BYTE_ORDER
#endif
#ifndef __BIG_ENDIAN
#define __BIG_ENDIAN BIG_ENDIAN
#endif
#ifndef __LITTLE_ENDIAN
#define __LITTLE_ENDIAN LITTLE_ENDIAN
#endif
SHIM
    sed -i.bak "s#-include cstdint#-I${SRC_DIR}/compat -include cstdint#" src/irfinder/Release/src/*/subdir.mk src/irfinder/Release/src/subdir.mk
    find src/irfinder -name '*.bak' -delete
fi

# Remove the prebuilt binaries / unused model shipped in the repository
rm -f bin/util/irfinder bin/util/irfinder_cnn bin/util/trim bin/util/winflat
rm -f bin/util/model/best_model.h5

(cd src/irfinder/Release && make -j"${CPU_COUNT}" && cp irfinder "${SRC_DIR}/bin/util/")
(cd src/trim && make -j"${CPU_COUNT}" trim CC="${CXX}" LDFLAGS="${LDFLAGS}" && cp trim "${SRC_DIR}/bin/util/")
(cd src/winflat && make winflat CC="${CC}" && cp winflat "${SRC_DIR}/bin/util/")

# CNN validator: upstream ships a prebuilt binary; install the python sources instead.
# tflite_runtime is not packaged on conda-forge, so fall back to tensorflow.lite.
CNN_SRC=src/cnnfilter/testCNN
sed -i.bak 's/^import tflite_runtime.interpreter as tflite$/try:\n    import tflite_runtime.interpreter as tflite\nexcept ImportError:\n    from tensorflow import lite as tflite/' ${CNN_SRC}/actions/models.py
rm -f ${CNN_SRC}/actions/models.py.bak
grep -q "from tensorflow import lite" ${CNN_SRC}/actions/models.py

irfinder_home="${PREFIX}/opt/irfinder-${PKG_VERSION}"
mkdir -p "${irfinder_home}/bin" "${PREFIX}/bin"
cp -r bin/. "${irfinder_home}/bin/"
cp -r REF "${irfinder_home}/"
mkdir -p "${irfinder_home}/bin/util/cnn"
cp -r ${CNN_SRC}/. "${irfinder_home}/bin/util/cnn/"
rm -rf "${irfinder_home}/bin/util/cnn/model"

# irfinder_cnn is called by IRFinderBAM as ${LIBEXEC}/irfinder_cnn
cat > "${irfinder_home}/bin/util/irfinder_cnn" <<'WRAP'
#!/bin/bash
DIR=$(dirname "$(readlink -nf "${BASH_SOURCE[0]}")")/cnn
exec python "${DIR}/irfinder_cnn.py" "$@"
WRAP
chmod -R a+rx "${irfinder_home}/bin"

# Expose the entry points
ln -s "${irfinder_home}/bin/IRFinder" "${PREFIX}/bin/IRFinder"
ln -s "${irfinder_home}/bin/util/cnn/irfinder_cnn.py" "${PREFIX}/bin/irfinder_cnn.py"

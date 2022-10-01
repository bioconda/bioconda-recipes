#!/bin/bash

set -euxo pipefail

${PYTHON} -m pip install -vv --no-deps --ignore-installed .

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/bin/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin

cp -f "${SRC_DIR}/pavfinder/scripts/fusion-bloom" "${PREFIX}/bin/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/fusion-bloom"

echo "#!/bin/bash" > ${PREFIX}/bin/fusion-bloom
echo "make -f $(command -v ${PREFIX}/bin/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/fusion-bloom) \$@" >> ${PREFIX}/bin/fusion-bloom
chmod +x ${PREFIX}/bin/fusion-bloom


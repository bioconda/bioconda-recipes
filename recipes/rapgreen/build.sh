#!/bin/bash
set -eux -o pipefail

# Prepare share folder 
RAPGREEN_DIR=${PREFIX}/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p ${RAPGREEN_DIR}

# take care of the jar and copy it into the share folder
mkdir -p "$PREFIX/bin"
cp -rf ${SRC_DIR}/bin/* ${RAPGREEN_DIR}

# Handle python wrapper script that will call the jar file
cp ${RECIPE_DIR}/rapgreen.py ${RAPGREEN_DIR}/
printf '#!/bin/bash\n' > ${RAPGREEN_DIR}/rapgreen
printf "cd ${RAPGREEN_DIR} \n" >> ${RAPGREEN_DIR}/rapgreen
printf 'python rapgreen.py "$@"\n' >> ${RAPGREEN_DIR}/rapgreen
ln -s ${RAPGREEN_DIR}/rapgreen ${PREFIX}/bin/

# Make executable in the share folder
chmod +x ${RAPGREEN_DIR}/*


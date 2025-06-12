#!/bin/bash

set -exuo pipefail

sed -i.bak \
    -e "s|\$MVIEW_HOME = \"/home/brown/HOME/work/MView/dev\";|\$MVIEW_HOME = \$ENV{'CONDA_PREFIX'} if exists \$ENV{'CONDA_PREFIX'};|" \
    -e 's|$MVIEW_LIB = "$MVIEW_HOME/lib";|$MVIEW_LIB = "$MVIEW_HOME/lib/mview'${PKG_VERSION}'";|' \
    ${SRC_DIR}/bin/mview

LIB_INSTALL_DIR=${PREFIX}/lib/mview${PKG_VERSION}

mkdir -p ${LIB_INSTALL_DIR}/Bio
cp -r ${SRC_DIR}/lib/Bio/{MView,Parse,Util} ${LIB_INSTALL_DIR}/Bio/

install -D -m 755 ${SRC_DIR}/bin/mview ${PREFIX}/bin/

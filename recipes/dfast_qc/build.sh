#!/bin/sh

APPROOT="${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}"


mkdir -p ${APPROOT}
mkdir -p ${PREFIX}/bin
# cp -av . ${APPROOT}
cp -av dqc $APPROOT/dqc
cp -v dfast_qc $APPROOT
cp -v dqc_admin_tools.py $APPROOT
cp -v initial_setup.sh $APPROOT


# cd ${PREFIX}/bin
ln -s ${APPROOT}/dfast_qc ${PREFIX}/bin/dfast_qc
ln -s ${APPROOT}/dqc_admin_tools.py ${PREFIX}/bin/dqc_admin_tools.py


${PREFIX}/bin/dfast_qc --version

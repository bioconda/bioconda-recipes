#!/bin/sh

APPROOT="${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}"


mkdir -p ${APPROOT}
mkdir -p ${PREFIX}/bin
cp -av . ${APPROOT}
# cp -r dqc $APPROOT/dqc
# cp dfast_qc $APPROOT
# cp dqc_admin_tools.py $APPROOT
# cp initial_setup.sh $APPROOT


# cd ${PREFIX}/bin
ln -s ${APPROOT}/dfast_qc ${PREFIX}/bin/dfast_qc
ln -s ${APPROOT}/dqc_admin_tools.py ${PREFIX}/bin/dqc_admin_tools.py



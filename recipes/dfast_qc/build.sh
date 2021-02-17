#!/bin/sh

APPROOT="${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}"


mkdir -p ${APPROOT}
mkdir -p ${PREFIX}/bin
cp -Rv ./* ${APPROOT}/
# cp -av dqc $APPROOT/dqc
# cp -v dfast_qc $APPROOT
# cp -v dqc_admin_tools.py $APPROOT
# cp -v initial_setup.sh $APPROOT

# cp -av dqc ${PREFIX}/bin/dqc
# cp -v dfast_qc ${PREFIX}/bin
# cp -v dqc_admin_tools.py ${PREFIX}/bin
# cp -v initial_setup.sh ${PREFIX}/bin

# cd ${PREFIX}/bin
ln -s ${APPROOT}/dfast_qc ${PREFIX}/bin/
ln -s ${APPROOT}/dqc_admin_tools.py ${PREFIX}/bin/
ln -s ${APPROOT}/initial_setup.sh ${PREFIX}/bin/dqc_initial_setup.sh

# ${PREFIX}/bin/dfast_qc --version
dfast_qc --version
dfast_qc -h

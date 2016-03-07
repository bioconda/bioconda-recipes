#!/bin/bash

# Use internal htslib
chmod a+x ./htslib/configure
export CFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
export HTSLIB_CONFIGURE_OPTIONS="--disable-libcurl"

# Use --old-and-unmanageable to disable egg-style folder naming, which is a minor hassle for RPATH stuff.
$PYTHON setup.py install --old-and-unmanageable

# Hacky workaround to fix rpath pathing issues
if [ "$(uname)" == "Darwin" ]; then
  otool -L ${SP_DIR}/pysam/*.so
  install_name_tool -change @rpath/pysam/libchtslib.so @rpath/python${PY_VER}/site-packages/pysam/libchtslib.so ${SP_DIR}/pysam/calignedsegment.so
  install_name_tool -change @rpath/pysam/libchtslib.so @rpath/python${PY_VER}/site-packages/pysam/libchtslib.so ${SP_DIR}/pysam/calignmentfile.so
  install_name_tool -change @rpath/pysam/libchtslib.so @rpath/python${PY_VER}/site-packages/pysam/libchtslib.so ${SP_DIR}/pysam/cbcf.so
  install_name_tool -change @rpath/pysam/libchtslib.so @rpath/python${PY_VER}/site-packages/pysam/libchtslib.so ${SP_DIR}/pysam/cfaidx.so
  install_name_tool -change @rpath/pysam/libchtslib.so @rpath/python${PY_VER}/site-packages/pysam/libchtslib.so ${SP_DIR}/pysam/csamfile.so
  install_name_tool -change @rpath/pysam/libchtslib.so @rpath/python${PY_VER}/site-packages/pysam/libchtslib.so ${SP_DIR}/pysam/ctabix.so
  install_name_tool -change @rpath/pysam/libchtslib.so @rpath/python${PY_VER}/site-packages/pysam/libchtslib.so ${SP_DIR}/pysam/ctabixproxies.so
  install_name_tool -change @rpath/pysam/libchtslib.so @rpath/python${PY_VER}/site-packages/pysam/libchtslib.so ${SP_DIR}/pysam/cutils.so
  install_name_tool -change @rpath/pysam/libchtslib.so @rpath/python${PY_VER}/site-packages/pysam/libchtslib.so ${SP_DIR}/pysam/cvcf.so
  otool -L ${SP_DIR}/pysam/*.so
else
	echo "Skipping rpath workaround on linux"
fi

#!/bin/bash
if [ `uname` == Darwin ]; then
    SO_EXT='dylib'
else
    SO_EXT='so'
fi

PYTHON_INCLUDE_DIR=$($PYTHON -c 'import distutils.sysconfig, sys; sys.stdout.write(distutils.sysconfig.get_python_inc())')
PYTHON_LIBRARY=$($PYTHON -c 'from distutils.sysconfig import get_config_var; import os, sys; sys.stdout.write(os.path.join(get_config_var("LIBDIR"),get_config_var("LDLIBRARY")))')

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DPYTHON_LIBRARY=$PYTHON_LIBRARY \
      -DPYTHON_EXECUTABLE=$PYTHON \
      -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR \
      -DPYTHON_BINDINGS=ON \
      -DLIBXML2_INCLUDE_DIR=$PREFIX/include \
      -DLIBXML2_LIBRARIES=$PREFIX/lib/libxml2.${SO_EXT} \
      -DZLIB_INCLUDE_DIR=$PREFIX/include \
      -DZLIB_LIBRARY=$PREFIX/lib/libz.${SO_EXT} \
      -DRUN_SWIG=ON

make -j${CPU_COUNT}
make install

cd scripts/python
OPENBABEL_INCLUDE_DIRS=$(pwd)/..:$PREFIX/include/openbabel-2.0 python setup.py install

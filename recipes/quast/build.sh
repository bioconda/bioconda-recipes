#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib

export CXXFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR}"
export CFLAGS="-DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"

BINARY_HOME=$PREFIX/bin
QUAST_HOME=$PREFIX/opt/quast-$PKG_VERSION

mkdir -p $BINARY_HOME
mkdir -p $QUAST_HOME

python "setup.py" install_full

cp -R $SRC_DIR/*quast.py $QUAST_HOME/
cp -R $SRC_DIR/icarus.py $QUAST_HOME/

lib_path=`python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`

ln -s $lib_path/quast_libs $QUAST_HOME/quast_libs

#Linking to binfolder
chmod +x $QUAST_HOME/quast.py
ln -s "$QUAST_HOME/quast.py" "$BINARY_HOME/quast"

chmod +x $QUAST_HOME/metaquast.py
ln -s "$QUAST_HOME/metaquast.py" "$BINARY_HOME/metaquast"

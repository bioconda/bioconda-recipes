#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

BINARY_HOME=$PREFIX/bin
QUAST_HOME=$PREFIX/opt/quast-$PKG_VERSION

mkdir -p $BINARY_HOME
mkdir -p $QUAST_HOME

rm -r $SRC_DIR/quast_libs/site_packages/joblib*
rm -r $SRC_DIR/quast_libs/site_packages/simplejson

python "setup.py" install

cp -R $SRC_DIR/*quast*.py $QUAST_HOME/
cp -R $SRC_DIR/icarus.py $QUAST_HOME/

lib_path=`python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`

ln -s $lib_path/quast_libs $QUAST_HOME/quast_libs

#Linking to binfolder
chmod +x $QUAST_HOME/quast.py
ln -s "$QUAST_HOME/quast.py" "$BINARY_HOME/quast"

chmod +x $QUAST_HOME/metaquast.py
ln -s "$QUAST_HOME/metaquast.py" "$BINARY_HOME/metaquast"

cp $RECIPE_DIR/quast-download-* $PREFIX/bin
chmod +x $PREFIX/bin/quast-download-*

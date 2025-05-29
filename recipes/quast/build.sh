#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

BINARY_HOME=$PREFIX/bin
QUAST_HOME=$PREFIX/opt/quast-$PKG_VERSION

mkdir -p $BINARY_HOME
mkdir -p $QUAST_HOME

rm -rf $SRC_DIR/quast_libs/site_packages/joblib*
rm -rf $SRC_DIR/quast_libs/site_packages/simplejson

sed -i.bak 's/CC=/#CC=/' $SRC_DIR/quast_libs/bwa/Makefile
sed -i.bak 's/INCLUDES=/#INCLUDES=/' $SRC_DIR/quast_libs/bwa/Makefile
sed -i.bak 's/CFLAGS=/CFLAGS+= -fcommon/' $SRC_DIR/quast_libs/bwa/Makefile

sed -i.bak 's/export CXX\s/#export CXX/' $SRC_DIR/quast_libs/bedtools/Makefile
sed -i.bak 's/CXXFLAGS =/CXXFLAGS +=/' $SRC_DIR/quast_libs/bedtools/Makefile

# Fails on OSX
#pushd $SRC_DIR/quast_libs/bedtools/
#make
#cp ./bin/* ${PREFIX}/bin
#popd

$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv

tail -n50 $SRC_DIR/quast_libs/*/make.* || true

cp -R $SRC_DIR/*quast*.py $QUAST_HOME/
cp -R $SRC_DIR/icarus.py $QUAST_HOME/

lib_path=`python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`

ln -sf $lib_path/quast_libs $QUAST_HOME/quast_libs

#Linking to binfolder
chmod +x $QUAST_HOME/quast.py
ln -sf "$QUAST_HOME/quast.py" "$BINARY_HOME/quast"

chmod +x $QUAST_HOME/metaquast.py
ln -sf "$QUAST_HOME/metaquast.py" "$BINARY_HOME/metaquast"

cp -rf $RECIPE_DIR/quast-download-* $PREFIX/bin
chmod +x $PREFIX/bin/quast-download-*

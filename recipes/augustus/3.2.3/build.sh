#!/bin/bash

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR=${PREFIX}/include
export BOOST_LIBRARY_DIR=${PREFIX}/lib

#export CXXFLAGS=" -std=c++11 -stdlib=libstdc++ -stdlib=libc++ -DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export CXXFLAGS=" -std=c++11  -DUSE_BOOST -I${BOOST_INCLUDE_DIR} -L${BOOST_LIBRARY_DIR}"
export LDFLAGS="-L${BOOST_LIBRARY_DIR}"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/scripts
mkdir -p $PREFIX/config

## Make the software

sed -i.bak -e 's/^CC *=/CXX=/' -e 's/\$(CC)/$(CXX)/g' auxprogs/homGeneMapping/src/Makefile
sed -i.bak -e 's/^CC *=/CXX=/' -e 's/\$(CC)/$(CXX)/g' auxprogs/joingenes/Makefile
# TODO: don't set CC/CXX here when switching to newer compilers
CC=gcc
CXX=g++
if [ "$(uname)" == Darwin ] ; then
  # SQLITE disabled due to compile issue, see: https://svn.boost.org/trac10/ticket/13501
  make CC="${CC}" CXX="${CXX}" COMPGENPRED=true
else
  make CC="${CC}" CXX="${CXX}" COMPGENPRED=true SQLITE=true
fi

## Build Perl

mkdir perl-build
find scripts -name "*.pl" | xargs -I {} mv {} perl-build
cd perl-build
cp ${RECIPE_DIR}/Build.PL ./
perl ./Build.PL
perl ./Build manifest
perl ./Build install --installdirs site

cd ..

## End build perl

mv bin/* $PREFIX/bin/
mv scripts/* $PREFIX/bin/
mv config/* $PREFIX/config/

#Add some options to activate

mkdir -p $PREFIX/etc/conda/activate.d/
echo "export AUGUSTUS_CONFIG_PATH=$PREFIX/config/" > $PREFIX/etc/conda/activate.d/augustus-confdir.sh
chmod a+x $PREFIX/etc/conda/activate.d/augustus-confdir.sh

mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset AUGUSTUS_CONFIG_PATH" > $PREFIX/etc/conda/deactivate.d/augustus-confdir.sh
chmod a+x $PREFIX/etc/conda/deactivate.d/augustus-confdir.sh

chmod u+rwx $PREFIX/bin/*

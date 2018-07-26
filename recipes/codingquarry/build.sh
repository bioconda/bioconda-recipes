#!/bin/sh

#modify makefile to use correct compiler c++
sed -i.bak -e 's/\${CC}/${CXX}/g' -e 's/\${CFLAGS}/${CXXFLAGS}/g' makefile

if [ "$(uname)" == Darwin ] ; then
  CXXFLAGS="-Wl,-rpath ${PREFIX}/lib -L${PREFIX}/lib -fopenmp"
else
  CXXFLAGS="-fopenmp -g -O3"
fi

#now build
make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}"

#link
mkdir -p $PREFIX/bin
mv CodingQuarry $PREFIX/bin
cp -R $SRC_DIR/QuarryFiles ${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}/QuarryFiles

#required ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export QUARRYFILES=${PREFIX}/share/codingquarry/QuarryFiles" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh

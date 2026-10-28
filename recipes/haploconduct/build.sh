#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include

make CC=$CXX CPPFLAGS="-Wall -fopenmp -std=c++11 -g -O2 -L$PREFIX/lib"
mkdir -p $PREFIX/bin

PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $PACKAGE_HOME

cp -r bin quick-cliques scripts haploconduct.py $PACKAGE_HOME/
cp savage.py estimate_strain_count.py polyte.py polyte-split.py $PACKAGE_HOME/

WRAPPER=$PREFIX/bin/haploconduct
echo "#!/bin/sh" > $WRAPPER
echo "$PACKAGE_HOME/haploconduct.py \$@" >> $WRAPPER
chmod +x $WRAPPER

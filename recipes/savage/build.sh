#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
mkdir -p $PREFIX/bin

PACKAGE_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $PACKAGE_HOME

cp -r bin quick-cliques scripts savage.py estimate_strain_count.py $PACKAGE_HOME/
# ln -rs $PACKAGE_HOME/savage.py $PREFIX/bin/savage # create a symbolic link
WRAPPER=$PREFIX/bin/savage
echo "#!/bin/sh" > $WRAPPER
echo "$PACKAGE_HOME/savage.py \$@" >> $WRAPPER
chmod +x $WRAPPER

#!/bin/bash

export CFLAGS="-I$CONDA_PREFIX/include"
export LDFLAGS="-L$CONDA_PREFIX/lib"
export CPATH=${PREFIX}/include

echo "run git submodule update --init --recursive"
git submodule update --init --recursive


ln -s ${CC} ${PREFIX}/bin/gcc
ln -s ${CXX} ${PREFIX}/bin/g++

# modify the bugs in the makefiles
echo "modify the bugs in the makefiles"
sed -i 's/\$$//' $SRC_DIR/src/makefile
sed -i 's/= ..\/build/= .\/build/' $SRC_DIR/makefile

make -j

# create and populate binary file
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/
cp -r build/bin/* $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/

# create calling script
mkdir -p $PREFIX/bin/
cat <<EOF > $PREFIX/bin/pecat.pl
#!/bin/bash

$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/pecat.pl "\$@"
EOF

chmod +x $PREFIX/bin/pecat.pl

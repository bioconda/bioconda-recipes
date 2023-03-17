#!/bin/bash

export CFLAGS="-I$CONDA_PREFIX/include"
export LDFLAGS="-L$CONDA_PREFIX/lib"
export CPATH=${PREFIX}/include


git submodule update --init --recursive

# modify the bugs in the makefiles
set -i 's/\$$//' src/makefile
set -i 's/= ..\/build/= .\/build/' makefile

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

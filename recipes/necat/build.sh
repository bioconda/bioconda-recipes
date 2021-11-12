#!/bin/bash
set -ex

export CFLAGS="$CFLAGS  -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS  -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# build
make -C src CFLAGS+="${CFLAGS}" LDFLAGS+="${LDFLAGS}" CXXFLAGS+="${CXXFLAGS}"

# create and populate binary file
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/
cp -r Linux-amd64/bin/*  $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/

# create calling script
mkdir $PREFIX/bin/
cat <<EOF > $PREFIX/bin/necat
#!/bin/bash

PATH=\$PATH:$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/ necat.pl "\$@"
EOF

chmod +x $PREFIX/bin/necat

#!/bin/bash
set -ex

export CFLAGS="$CFLAGS  -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS  -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

BIN_ROOT="Linux-amd64/bin"
case $(uname -m) in
    arm64|aarch64) BIN_ROOT="Linux-aarch64/bin" ;;
esac
# build
make -C src CFLAGS+="${CFLAGS}" LDFLAGS+="${LDFLAGS}" CXXFLAGS+="${CXXFLAGS}"

# create and populate binary file
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/
cp -r $BIN_ROOT/*  $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/

# create calling script
mkdir $PREFIX/bin/
cat <<EOF > $PREFIX/bin/necat
#!/bin/bash

PATH=\$PATH:$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/ necat.pl "\$@"
EOF

chmod +x $PREFIX/bin/necat

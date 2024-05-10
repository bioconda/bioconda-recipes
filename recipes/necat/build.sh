#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

BIN_ROOT="Linux-amd64/bin"
case $(uname -m) in
    arm64|aarch64) BIN_ROOT="Linux-aarch64/bin" ;;
esac

# build
make -C src CFLAGS+="${CFLAGS}" LDFLAGS+="${LDFLAGS}" CXXFLAGS+="${CXXFLAGS}" -j"${CPU_COUNT}"

# create and populate binary file
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/
cp -rf $BIN_ROOT/*  $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/

# create calling script
mkdir -p ${PREFIX}/bin/
cat <<EOF > $PREFIX/bin/necat
#!/bin/bash

PATH=\$PATH:$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/ necat.pl "\$@"
EOF

chmod 755 ${PREFIX}/bin/necat

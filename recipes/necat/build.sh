#!/bin/bash
set -ex

mkdir -p ${PREFIX}/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-incompatible-function-pointer-types -Wno-implicit-function-declaration -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

case $(uname -m) in
    aarch64) BIN_ROOT="Linux-aarch64/bin" ;;
    arm64) BIN_ROOT="Darwin-arm64/bin" ;;
    x86_64) BIN_ROOT="Linux-amd64/bin" ;;
esac

if [[ "$(uname)" == "Darwin" && "$(uname -m)" == "x86_64" ]]; then
	BIN_ROOT="Darwin-amd64/bin"
fi

# build
make -C src CFLAGS+="${CFLAGS}" LDFLAGS+="${LDFLAGS}" CXXFLAGS+="${CXXFLAGS}" -j"${CPU_COUNT}"

# create and populate binary file
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin
cp -rf $BIN_ROOT/Plgd $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin && rm -rf $BIN_ROOT/Plgd
rm -rf $BIN_ROOT/trim_bases_accurate*
install -v -m 0755 $BIN_ROOT/* "${PREFIX}/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin"

# create calling script
cat <<EOF > $PREFIX/bin/necat
#!/bin/bash

PATH=\$PATH:$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/ necat.pl "\$@"
EOF

chmod 0755 ${PREFIX}/bin/necat

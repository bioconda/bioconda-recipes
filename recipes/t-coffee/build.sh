#!/bin/bash
#
# CONDA build script variables 
# 
# $PREFIX The install prefix
# $PKG_NAME The name of the package
# $PKG_VERSION The version of the package
# $PKG_BUILDNUM The build number of the package
#
set -eux -o pipefail
# silence some LANG perl warning messages:
export LANG=C.UTF-8

SHARE_DIR="${PREFIX}/libexec/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OS=$(./install get_os)

cd t_coffee_source
# CC=CXX is correct here - the t-coffee authors use this as it errors less with the source.
make -j ${CPU_COUNT} CFLAGS="${CFLAGS} -fsigned-char -Wno-write-strings" CC="${CXX}" LDFLAGS="${LDFLAGS}" FCC="${FC}" FFLAGS="${FFLAGS}" all
cp t_coffee TMalign ../bin/${OS}
cd ..
mkdir -p "${PREFIX}/bin"

# the t-coffee home only has plugins with x86_64 support; let's not 
# download them. Instead use only bioconda's own installs.
if [ "$(uname -m)" = "aarch64" ]
then
  ./install t_coffee -tcdir="${SHARE_DIR}"
    
else
  ./install all -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS"
fi

# llvm-otool -l fails for these plugins on macosx
if [ "$OS" = macosx ]
then
    for bad_plug in probconsRNA prank
    do
	rm -fv "${SHARE_DIR}/plugins/macosx/${bad_plug}"
    done
fi

# The installer may try to update dependencies and install them to bin/,
# which will cause conflicts with the dependencies as separately packaged.
# t_coffee itself is not installed here
rm -fv ${PREFIX}/bin/*

sed -e "s|CHANGEME|${SHARE_DIR}|" -e "s|__OS__|${OS}|" "$RECIPE_DIR/t_coffee.sh" > "${PREFIX}/bin/t_coffee"

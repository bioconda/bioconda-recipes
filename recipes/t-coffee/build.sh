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

SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OS=$(./install get_os)

mkdir -p "${PREFIX}/bin"

./install t_coffee -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register -L${PREFIX}/lib"
./install tcoffee -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register -L${PREFIX}/lib"
./install rcoffee -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register -L${PREFIX}/lib"
./install seq_reformat -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register -L${PREFIX}/lib"
./install expresso -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register -L${PREFIX}/lib"
./install psicoffee -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register -L${PREFIX}/lib"
./install trmsd -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register -L${PREFIX}/lib"
./install accurate -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register -L${PREFIX}/lib"
./install 3dcoffee -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register -L${PREFIX}/lib"
./install mcoffee -tcdir="${SHARE_DIR}" CC="$CXX" CFLAGS="$CFLAGS -O3 -Wno-register -L${PREFIX}/lib"

# llvm-otool -l fails for these plugins on macosx
if [[ `uname` == "Darwin" ]]; then
    for bad_plug in probconsRNA prank
    do
	rm -f "${SHARE_DIR}/plugins/macosx/${bad_plug}"
    done
fi

# The installer may try to update dependencies and install them to bin/,
# which will cause conflicts with the dependencies as separately packaged.
# t_coffee itself is not installed here
# rm -fv ${PREFIX}/bin/*

sed -e "s|CHANGEME|${SHARE_DIR}|" -e "s|__OS__|${OS}|" "$RECIPE_DIR/t_coffee.sh" > "${PREFIX}/bin/t_coffee"

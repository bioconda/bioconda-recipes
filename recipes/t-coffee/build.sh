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

# -fsigned-char is needed for aarch64; register needs to be hidden for os-x's C++ compiler
CFLAGS="${CFLAGS} -fsigned-char -Wno-write-strings -Dregister='' -O0"

rm -fv bin/${OS}/*			# remove the download binaries - we rebuild

cd t_coffee_source
make -j ${CPU_COUNT} CFLAGS="${CFLAGS} -fsigned-char -Wno-write-strings -Dregister='' -O0" CC="${CXX}" LDFLAGS="${LDFLAGS}" FCC="${FC}" FFLAGS="${FFLAGS}" all
cp t_coffee TMalign ../bin/${OS}/ # overwrite the distributed x86 linux binary 
cd ..

mkdir -p "${PREFIX}/bin"

# the t-coffee home only has plugins with x86_64 support; let's not 
# download them. Instead use only bioconda's own installs.
# the t_coffee application is the only one from the set required by Bio::Tools::Run::Alignment::TCoffee
./install t_coffee -tcdir="${SHARE_DIR}" CC="${CXX}" CFLAGS="${CFLAGS}"

# # llvm-otool -l fails for these plugins on macosx
# if [ "$OS" = macosx ]
# then
#     for bad_plug in probconsRNA prank
#     do
# 	rm -fv "${SHARE_DIR}/plugins/macosx/${bad_plug}"
#     done
# fi

# The installer may try to update dependencies and install them to bin/,
# which will cause conflicts with the dependencies as separately packaged.
# t_coffee itself is not installed here
rm -fv ${PREFIX}/bin/*

sed -e "s|CHANGEME|${SHARE_DIR}|" -e "s|__OS__|${OS}|" "$RECIPE_DIR/t_coffee.sh" > "${PREFIX}/bin/t_coffee"


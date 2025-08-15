#!/bin/bash
set -eux -o pipefail
#
# CONDA build script variables
#
# $PREFIX The install prefix
# $PKG_NAME The name of the package
# $PKG_VERSION The version of the package
# $PKG_BUILDNUM The build number of the package
#

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
# -fsigned-char is needed for aarch64; register needs to be hidden for os-x's C++ compiler
export CFLAGS="${CFLAGS} -O3 -fsigned-char -Wno-write-strings -Dregister=''"

if [[ "$(uname -s)" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
fi

# silence some LANG perl warning messages:
export LC_ALL="en_US.UTF-8"

export SHARE_DIR="${PREFIX}/libexec/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OS=$(./install get_os)

rm -fv bin/${OS}/*			# remove the download binaries - we rebuild

cd t_coffee_source
make all CFLAGS="${CFLAGS}" CC="${CXX}" LDFLAGS="${LDFLAGS}" FCC="${FC}" FFLAGS="${FFLAGS}" -j"${CPU_COUNT}"

cp -f t_coffee TMalign ../bin/${OS}/    # overwrite the distributed x86 linux binary
cd ..

# the t-coffee home only has plugins with x86_64 support; let's not
# download them. Instead use only bioconda's own installs.
# the t_coffee application is the only one from the set required by Bio::Tools::Run::Alignment::TCoffee
./install t_coffee -tcdir="${SHARE_DIR}" CC="${CXX}" CFLAGS="${CFLAGS}"

# The installer may try to update dependencies and install them to bin/,
# which will cause conflicts with the dependencies as separately packaged.
# t_coffee itself is not installed here
rm -fv ${PREFIX}/bin/*

sed -e "s|CHANGEME|${SHARE_DIR}|" -e "s|__OS__|${OS}|" "$RECIPE_DIR/t_coffee.sh" > "${PREFIX}/bin/t_coffee"

#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:"${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p "${outdir}/libexec" "$PREFIX/bin"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

# src/Makefile uses
# > CXX = g++
# > CXXFLAGS = -Wall -fopenmp -O3
# We patch these to add to environment, rather than override
# because we can't get to the `make` call easily.
sed -i.bak 's/CXX *=/CXX ?=/; s/CXXFLAGS *=/CXXFLAGS +=/' src/Makefile

# Work around "unknown type name 'mach_port_t'" error
if [ x"$(uname)" == x"Darwin" ]; then
  CXXFLAGS="$CXXFLAGS -D_DARWIN_C_SOURCE"
  CPPFLAGS="$CPPFLAGS -D_DARWIN_C_SOURCE"
  export CXXFLAGS CPPFLAGS
fi

chmod u+x install_kraken.sh
./install_kraken.sh "${outdir}/libexec"
for bin in kraken kraken-build kraken-filter kraken-mpa-report kraken-report kraken-translate; do
    chmod +x "${outdir}/libexec/$bin"
    ln -s "${outdir}/libexec/$bin" "$PREFIX/bin/$bin"
    # Change from double quotes to single in case of special chars
    sed -i.bak "s#my \$KRAKEN_DIR = \"${outdir}/libexec\";#my \$KRAKEN_DIR = '${outdir}/libexec';#g" "${outdir}/libexec/${bin}"
    rm -rf "${outdir}/libexec/${bin}.bak"
done

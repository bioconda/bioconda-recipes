#!/bin/bash
export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${PREFIX}/include
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p "${outdir}/libexec" "$PREFIX/bin"

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

chmod u+x install_krakenuniq.sh
./install_krakenuniq.sh "${outdir}/libexec"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${outdir}/libexec/krakenuniq-extract-reads

sed -i.bak 's#$script_dir/jellyfish-install/bin/jellyfish#jellyfish#g' "${outdir}/libexec/build_db.sh"
ln -s "${outdir}/libexec/build_taxdb" "$PREFIX/bin/build_taxdb"

for bin in krakenuniq krakenuniq-build krakenuniq-download krakenuniq-extract-reads krakenuniq-filter krakenuniq-mpa-report krakenuniq-report krakenuniq-translate read_merger.pl; do
    chmod +x "${outdir}/libexec/$bin"
    ln -s "${outdir}/libexec/$bin" "$PREFIX/bin/$bin"
    # Change from double quotes to single in case of special chars
    sed -i.bak "s#my \$KRAKEN_DIR = \"${outdir}/libexec\";#my \$KRAKEN_DIR = '${outdir}/libexec';#g" "${outdir}/libexec/${bin}"
    rm -rf "${outdir}/libexec/${bin}.bak"
done

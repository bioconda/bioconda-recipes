#!/bin/bash
set -ex

# Set up compilers
export CC="${CC}"
export CXX="${CXX}"
export FC="${FC}"
export PERL="${PERL:-${BUILD_PREFIX}/bin/perl}"
export PYTHON="${PYTHON}"

# Create symbolic links for build tools
for tool in ar ld nm objdump ranlib; do
    if [[ -e "${PREFIX}/bin/x86_64-conda-linux-gnu-${tool}" ]]; then
        ln -sf "${PREFIX}/bin/x86_64-conda-linux-gnu-${tool}" "${PREFIX}/bin/${tool}" || true
    fi
done

# Set compilation flags
export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -lgsl -lgslcblas -lz -lgfortran -lstdc++ -lcurl -ltinfo -Wl,-rpath,${PREFIX}/lib"
export PERL_MM_USE_DEFAULT=1
export PERL_EXTUTILS_AUTOINSTALL="--defaultdeps"

# Ensure pkg-config finds GSL
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
pkg-config --modversion gsl || echo "WARNING: pkg-config cannot find GSL"

# Install Perl modules
export PERL_MM_USE_DEFAULT=1
${PERL} -MCPAN -e 'install CPAN' || true
${PERL} -MCPAN -e 'install CPAN::Meta' || true
${PERL} -MCPAN -e 'install Devel::CheckLib' || true
${PERL} -MCPAN -e 'install File::Which' || true
${PERL} -MCPAN -e 'install Capture::Tiny' || true
${PERL} -MCPAN -e 'install Mock::Config' || true

# Unset conflicting variables
unset build_alias host_alias

# Build and install HEAsoft
cd heasoft/BUILD_DIR
./configure --prefix="${PREFIX}" \
    --x-includes="${PREFIX}/include" \
    --x-libraries="${PREFIX}/lib" \
    --enable-static=no \
    --with-components="heacore ftools Xspec nustar suzaku swift integral ixpe heasim heagen heatools attitude"
make -j1
make install

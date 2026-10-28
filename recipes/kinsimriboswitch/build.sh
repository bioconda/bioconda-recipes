#!/bin/bash

##############################################################################
##                           Function definitions                           ##
##############################################################################

# Install a Perl distribution from a local source tarball.
# Copied from conda skeleton cpan's build.sh + tar calls.
install_perl_dist_tarball () {
    local dist_tarball="$1"
    if [ ! -s "$dist_tarball" ]; then
        echo "Distribution tarball '$dist_tarball' empty or non-existent."
        exit 1
    fi

    tar -xzf "$dist_tarball"
    cd "${dist_tarball%.tar.gz}"

    if [ -f Build.PL ]; then
        perl Build.PL
        perl ./Build
        perl ./Build test
        perl ./Build install --installdirs site
    elif [ -f Makefile.PL ]; then
        perl Makefile.PL INSTALLDIRS=site
        make
        make test
        make install
    else
        echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
        exit 1
    fi

    cd ..
}

install_bins () {
    cp "$@" "$PREFIX/bin/"
}

##############################################################################
##                                   Main                                   ##
##############################################################################

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib"

# Install binaries
install_bins "$SRC_DIR"/bin/*

# Install patched barriers
tar -xzf 'Barriers-1.5.2.tar.gz'
cd 'Barriers-1.5.2'
./configure
make
make check
install_bins 'barriers-RNA2'
cd ..

# Install patched Heap::Priority from local file
install_perl_dist_tarball 'Heap-Priority-0.11-mod.tar.gz'

# Install distribution-less Perl module RNAhelper.pm
mkdir -p "$PREFIX/lib/perl5_custom"
# Make sure this path is added to PERL5LIB in activate script!
cp "$SRC_DIR"/lib/perl5/* "$PREFIX/lib/perl5_custom/"

# Deploy activation / deactivation scripts
mkdir -p "$PREFIX/etc/conda/activate.d"
cp "$RECIPE_DIR/activate.sh" "$PREFIX/etc/conda/activate.d/$PKG_NAME-setenv.sh"
mkdir -p "$PREFIX/etc/conda/deactivate.d"
cp "$RECIPE_DIR/deactivate.sh" "$PREFIX/etc/conda/deactivate.d/$PKG_NAME-restoreenv.sh"

# Run tests
source "$RECIPE_DIR/activate.sh"           # make sure custom Perl modules are found
# make test # TODO enable
source "$RECIPE_DIR/deactivate.sh"         # make sure custom Perl modules are found

# EOF

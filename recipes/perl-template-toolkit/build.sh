#!/bin/bash

# Accept defaults so we don't get asked about building Template::Stash::XS
export PERL_MM_USE_DEFAULT=1
export LC_ALL="en_US.UTF-8"

# If it has Build.PL use that, otherwise use Makefile.PL
if [[ -f Build.PL ]]; then
    perl Build.PL
    ./Build
    ./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site NO_PACKLIST=1 NO_PERLLOCAL=1
    make -j"${CPU_COUNT}"
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

chmod +x $PREFIX/bin/ttree
chmod +x $PREFIX/bin/tpage

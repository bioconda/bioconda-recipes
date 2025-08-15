#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LC_ALL="en_US.UTF-8"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

sed -i.bak "s|^    cc => .*$|    cc => '${CC}',|" ${PREFIX}/lib/perl5/5.32/core_perl/Config.pm
rm -rf ${PREFIX}/lib/perl5/5.32/core_perl/*.bak

if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

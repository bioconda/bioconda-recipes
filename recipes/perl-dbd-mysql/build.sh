#!/bin/bash
set -ex

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
# Strip the broken relative --sysroot that perl's Config injects
export CCCDLFLAGS_FIXED="$(perl -MConfig -e 'my $f=$Config{cccdlflags}; $f=~s/--sysroot=\S+//g; print $f')"
export LDDLFLAGS_FIXED="$(perl -MConfig -e 'my $f=$Config{lddlflags}; $f=~s/--sysroot=\S+//g; print $f')"
export LC_ALL="C"

# If it has Build.PL use that, otherwise use Makefile.PL
if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site NO_PACKLIST=1 NO_PERLLOCAL=1 CCCDLFLAGS="${CCCDLFLAGS_FIXED}" LDDLFLAGS="${LDDLFLAGS_FIXED}"
    make -j"${CPU_COUNT}"
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

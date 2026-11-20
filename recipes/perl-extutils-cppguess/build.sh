#!/bin/bash

export LC_ALL="en_US.UTF-8"
# build.sh: drop perl's broken relative --sysroot from compile and shared-link flags;
# the conda compiler wrappers already know their own sysroot.
CCCDL=$(perl -MConfig -e '($s=$Config{cccdlflags}) =~ s/\s*--sysroot=\S+//g; print $s')
LDDL=$(perl -MConfig -e '($s=$Config{lddlflags}) =~ s/\s*--sysroot=\S+//g; print $s')
export PERL_MM_OPT="CCCDLFLAGS='${CCCDL}' LDDLFLAGS='${LDDL}'"

#rm -f t/002_icpp.t

if [[ -f Build.PL ]]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site NO_PACKLIST=1 NO_PERLLOCAL=1
    make
    make test -j"${CPU_COUNT}"
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

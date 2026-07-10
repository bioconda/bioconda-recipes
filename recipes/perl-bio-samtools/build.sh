#!/bin/bash

# Make sure pipes to tee don't hide configuration or test failures
set -o pipefail

export C_INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Tell the build system where to find samtools
export SAMTOOLS="${PREFIX}"
unset LD

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' bin/*.pl
rm -rf bin/*.bak

chmod 0755 bin/*.pl

chmod +w c_bin/makefile
sed -i.bak 's|-O2|-O3 -Wno-implicit-function-declaration|' c_bin/makefile
sed -i.bak 's|-lpthread|-pthread|' c_bin/makefile
rm -rf c_bin/*.bak

# If it has Build.PL use that, otherwise use Makefile.PL
if [[ -f Build.PL ]]; then
    perl Build.PL 2>&1 | tee configure.log
    perl ./Build
    perl ./Build test 2>&1 | tee tests.log
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [[ -f Makefile.PL ]]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make -j"${CPU_COUNT}"
    make test 2>&1
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

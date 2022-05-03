#!/bin/bash

# Make sure pipes to tee don't hide configuration or test failures
set -o pipefail

export C_INCLUDE_PATH=${PREFIX}/include

# Tell the build system where to find samtools
export SAMTOOLS="${PREFIX}"
unset LD

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL 2>&1 | tee configure.log
    perl ./Build
    perl ./Build test 2>&1 | tee tests.log
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test 2>&1
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

chmod +rx $PREFIX/bin/chrom_sizes.pl
chmod +rx $PREFIX/bin/bamToGBrowse.pl
chmod +rx $PREFIX/bin/genomeCoverageBed.pl

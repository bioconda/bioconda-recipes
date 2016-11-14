#!/bin/bash

# Make sure pipes to tee don't hide configuration or test failures
set -o pipefail

# Accept defaults so we don't get prompted about install options; resuls in:
#   * building all BioPerl scripts
#   * skipping test that require network access
export PERL_MM_USE_DEFAULT=1

echo "##++ PREFIX = $PREFIX";

ls $PREFIX/lib;
ls $PREFIX/lib64;

# ensure perl-gd is loaded properly or die trying
echo "##++ testing for perl GD library";
perl -e 'use GD;';
echo "##++ exist status for perl GD test = $?";

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    echo "##++ running Build.PL"
#    perl Build.PL 2>&1 | tee configure.log
    perl Build.PL 
    ./Build
#    ./Build test 2>&1 | tee tests.log
    ./Build test 
    # Make sure this goes in site
    ./Build install --installdirs site
#    ./Build install --install_path script=site
elif [ -f Makefile.PL ]; then
    echo "##++ running Makefile.PL"
    # Make sure this goes in site
#    perl Makefile.PL INSTALLDIRS=site 2>&1 | tee configure.log
    perl Makefile.PL INSTALLDIRS=site
    make
#    make test 2>&1 | tee tests.log
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

echo "##++ ls PREFIX"
ls -l $PREFIX

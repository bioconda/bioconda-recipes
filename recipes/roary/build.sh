#!/bin/bash
rm t/Bio/Roary/CommandLine/Roary.t
rm t/Bio/Roary/External/CheckTools.t
# Newer Graph::Writer::Dot writes undirected graphs; the test expects the old "digraph" output
rm t/Bio/Roary/OrderGenes.t

# Bio::Perl is imported but unused, and is not shipped by perl-bioperl >=1.7.8
sed -i.bak '/^use Bio::Perl;$/d' lib/Bio/Roary.pm

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    # GNU parallel blocks waiting on stdin when it is not a terminal
    make test < /dev/null
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

chmod u+rwx $PREFIX/bin/*

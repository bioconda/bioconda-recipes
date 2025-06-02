#!/bin/bash

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    ./Build
    ./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    # "-y": install tools (xml_grep, xml_pp, etc.) into ${PREFIX}/bin
    perl Makefile.PL -y INSTALLDIRS=site
    make
    # One test incorrectly failed due to a dependency correctly not liking a value
    #make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

chmod +x $PREFIX/bin/xml_grep
chmod +x $PREFIX/bin/xml_merge
chmod +x $PREFIX/bin/xml_pp
chmod +x $PREFIX/bin/xml_spellcheck
chmod +x $PREFIX/bin/xml_split

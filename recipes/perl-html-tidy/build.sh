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
    perl Makefile.PL INSTALLDIRS=site INC="-I${PREFIX}/include/tidyp" LIBS="-L${PREFIX}/lib"
    # By default the linked .so files are listed first, which obviously doesn't work for linking against tidyp.so
    sed -i.bak -e "s/\$(LDDLFLAGS)  \$(LDFROM)/\$(LDFROM) \$(LDDLFLAGS)/g" Makefile
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

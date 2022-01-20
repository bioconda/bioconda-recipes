#!/bin/bash
set -ex
export LDFLAGS="-Wl,-rpath,$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib -L$PREFIX/lib"
echo $LDFLAGS
# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site CC=${CC} DEBUG=1
    echo "FOOOOOOOOOOOOOOOOOOOOOOOOOOO"
    grep "-Wl,-O2" makefile
    env | grep "-Wl,-O2" || continue
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

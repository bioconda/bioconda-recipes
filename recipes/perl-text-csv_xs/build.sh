#!/bin/bash



# Fix pollution from the perl build environment
export CFLAGS="-I/usr/include $CFLAGS"
dname=`find $PREFIX/lib -name Config_heavy.pl -print | xargs dirname`
sed -i.bak "s|^    cc => .*$|    cc => '${CC}',|" ${dname}/Config.pm
sed -i.bak "s|^ccflags=.*$|ccflags='${CFLAGS}'|;s|^ld=.*$|ld='${CC}'|;s|^cppflags=.*$|cppflags='${CFLAGS}'|;" ${dname}/Config_heavy.pl

# clean up
rm -f ${dname}/Config.pm.bak ${dname}/Config_heavy.pl.bak


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
    # Fix pollution from the perl build environment
    sed -i.bak "s|^LDLOADLIBS = .*$|LDLOADLIBS = -L$PREFIX/lib -lssl -lcrypto -lz -lpthread|;s|/home/conda/feedstock_root/build_artifacts/perl_1550669032175/_build_env|$BUILD_PREFIX|g" Makefile
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

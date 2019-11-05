#!/bin/bash

export LD=$CC

CFLAGS="$CFLAGS -L$PREFIX/lib -I$PREFIX/include"
LIBS="$LDFLAGS -L$PREFIX/lib"
CPPFLAGS=$CFLAGS

# Compiling the kent source tree
export MACHTYPE=$(uname -m)
export KENT_SRC=$SRC_DIR/kent-335_base/src
export MYSQLINC="$(mysql_config --include | sed -e 's/^-I//g')"
export MYSQLLIBS="$(mysql_config --libs)"
echo 'CFLAGS="-fPIC"' > $KENT_SRC/inc/localEnvironment.mk
make -C $KENT_SRC/lib prefix=$PREFIX/ CC=$CC CFLAGS="$CFLAGS" LIBS="$LIBS"

# Building the module
export PERL5LIB=$PREFIX/lib/perl5/site_perl/5.22.0:$PERL5LIB
perl Build.PL --extra_compiler_flags "$CFLAGS" --extra_linker_flags "$CFLAGS"
perl ./Build
# Make sure this goes in site
perl ./Build install --installdirs site

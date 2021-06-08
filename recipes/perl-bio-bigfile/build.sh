#!/bin/bash

export LD=$CC

INCLUDES="-L$PREFIX/lib -I$PREFIX/include"
LIBS="-L$PREFIX/lib"
LDFLAGS="$LDFLAGS"
CFLAGS="$CFLAGS $INCLUDES"
CPPFLAGS=$CFLAGS

# Compiling the kent source tree
export MACHTYPE=$(uname -m)
export KENT_SRC=$SRC_DIR/kent-335_base/src
export MYSQLINC="$(mysql_config --include | sed -e 's/^-I//g')"
export MYSQLLIBS="$(mysql_config --libs)"
echo 'CFLAGS="-fPIC"' > $KENT_SRC/inc/localEnvironment.mk
make -C $KENT_SRC/lib prefix=$PREFIX/ CC=$CC CFLAGS="$CFLAGS" LIBS="$LIBS"

# Building the module
perl Build.PL
perl ./Build
# Make sure this goes in site
perl ./Build install --installdirs site

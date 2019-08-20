#!/bin/bash

# varfilter.py in install fails because we don't install Python
sed -i.bak 's#misc/varfilter.py##g' Makefile

# Remove rdynamic which can cause build issues on OSX
# https://sourceforge.net/p/samtools/mailman/message/34699333/
sed -i.bak 's/ -rdynamic//g' Makefile

# https://github.com/samtools/samtools/issues/577
if [[ "$(uname)" == "Linux" ]] ; then
    export LDFLAGS="$LDFLAGS -Wl,--add-needed"
fi

./configure --prefix=$PREFIX --with-htslib=system LDFLAGS="$LDFLAGS"
make all
make install

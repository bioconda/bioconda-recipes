#!/bin/bash

#htsversion=1.3.1
#htssource=samtools-${htsversion}/htslib-${htsversion}/
#
#sed -i.bak 's/^CPPFLAGS =$//g' ${htssource}/Makefile
#sed -i.bak 's/^LDFLAGS  =$//g' ${htssource}/Makefile 
#
#
## Remove rdynamic which can cause build issues on OSX
## https://sourceforge.net/p/samtools/mailman/message/34699333/
#sed -i.bak 's/ -rdynamic//g' ${htssource}/configure
#
#export CFLAGS="-I$PREFIX/include"
#export CPPFLAGS="-DHAVE_LIBDEFLATE -I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"
#
## https://github.com/samtools/samtools/issues/577
#if [[ "$(uname)" == "Linux" ]] ; then
#    export LDFLAGS="$LDFLAGS -Wl,--add-needed"
#fi

# disable Makefile driven build of htslib.a
sed -i.bak 's/.*build_ext.*//' setup.py

# just link to htslib
sed -i.bak 's/^extra_objects.*//' build.py
sed -i.bak 's/^libraries=\[/libraries=\["lhts",/' build.py

$PYTHON -m pip install . --no-deps --ignore-installed -vv

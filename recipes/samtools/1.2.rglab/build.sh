#!/bin/bash

sed -i.bak 's/^CPPFLAGS =$//g' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile
sed -i.bak 's|^INCLUDES=.*|INCLUDES = -I. -I$(HTSDIR) -I'$PREFIX'/include|' Makefile
#sed -i.bak -e 's/-lcurses/-lncurses/' Makefile
sed -i.bak -e '/^DFLAGS=/ s/-D_CURSES_LIB=1/-D_CURSES_LIB=0/g' Makefile
sed -i.bak -e '/^LIBCURSES=/ s/LIBCURSES/#LIBCURSES/' Makefile

sed -i.bak 's/^CPPFLAGS =$//g' htslib-1.2.1/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' htslib-1.2.1/Makefile

# varfilter.py in install fails because we don't install Python
sed -i.bak 's#misc/varfilter.py##g' Makefile

# Remove rdynamic which can cause build issues on OSX
# https://sourceforge.net/p/samtools/mailman/message/34699333/
sed -i.bak 's/ -rdynamic//g' Makefile
sed -i.bak 's/ -rdynamic//g' htslib-1.2.1/configure

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cd htslib*
./configure --prefix=$PREFIX --enable-libcurl CFLAGS="-I$PREFIX/include" LDFLAGS="$LDFLAGS"
make
cd ..
# Problem with ncurses from default channel we now get in bioconda so skip tview
# https://github.com/samtools/samtools/issues/577
if [[ "$(uname)" == "Linux" ]] ; then
    export LDFLAGS="$LDFLAGS -Wl,--add-needed"
fi

#./configure --prefix=$PREFIX --enable-libcurl --enable-plugins --with-plugin-path=$PWD/htslib-$PKG_VERSION LDFLAGS="$LDFLAGS" || (cat config.log ; false)
make install prefix=$PREFIX
#LIBS+=-lcrypto LIBS+=-lcurl

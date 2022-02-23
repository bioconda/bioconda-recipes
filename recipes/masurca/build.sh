#
set -x -e
export BOOST_ROOT=${PREFIX}
export DEST=${PREFIX}
export LDFLAGS="-L${PREFIX}/lib"
export CPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -std=gnu11"
export CXXFLAGS="$CXXFLAGS -std=gnu++14"

sed -i -e 's|cd Flye|LDFLAGS="-L $LIBDIR" \&\& cd Flye|' install.sh
sed -i -e 's|#-Wextra| ${LDFLAGS} #-Wextra|' Flye/lib/minimap2/Makefile
sed -i -e 's|version 4.0.5|version 4.0.8|' global-1/SuperReads/src/masurca

./install.sh


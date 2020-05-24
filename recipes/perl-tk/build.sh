#!/bin/bash
#--------------------------------------------------------------------------------
# MetTools - A Collection of Software for Meteorology and Remote Sensing
# Copyright (C) 2016  EUMETSAT
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#--------------------------------------------------------------------------------

export CXXFLAGS="-I${PREFIX}/include $CXXFLAGS"
export CPPFLAGS="-I${PREFIX}/include $CPPFLAGS"
export CFLAGS="-I${PREFIX}/include $CFLAGS"
export LDFLAGS="-L${PREFIX}/lib $LDFLAGS"
export DYLD_LIBRARY_PATH=${PREFIX}/lib
export AR="$AR cru"

#-----------------------------------------------------------
#  Configuration
#-----------------------------------------------------------

export PATH="${PREFIX}/bin:${PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"

#-----------------------------------------------------------
#  Build of package
#-----------------------------------------------------------

export X11INC=${PREFIX}/include
export X11LIB=${PREFIX}/lib

echo "==============================================================================================="
env
echo "==============================================================================================="

${PREFIX}/bin/perl Makefile.PL INSTALL_BASE=$PREFIX X11INC=${PREFIX}/include X11LIB=${PREFIX}/lib

make install

# fixing permissions (presumably bug in conda-build)
find ${PREFIX}/lib/perl5/x86_64-linux-thread-multi/auto/Tk/ -name "*.so" | xargs chmod -v u+w
find ${PREFIX}/bin -type f | xargs chmod -v u+w

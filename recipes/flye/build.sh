#!/bin/bash

#zlib headers for minimap
sed -i.bak 's/CFLAGS=/CFLAGS+=/' lib/minimap2/Makefile
sed -i.bak 's/INCLUDES=/INCLUDES+=/' lib/minimap2/Makefile
export CFLAGS="-L$PREFIX/lib"
export INCLUDES="-I$PREFIX/include"

#zlib headers for flye binaries
export CXXFLAGS="$CXXFLAGS -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

#install_name_tool error fix
if [[ "$(uname)" == Darwin ]]; then
    export LDFLAGS="$LDFLAGS -headerpad_max_install_names"
fi

#dynamic flag is needed for backtrace printing,
#but it seems it fails OSX build
sed -i.bak 's/-rdynamic//' src/Makefile

$PYTHON -m pip install --no-deps --no-build-isolation --no-cache-dir . -vvv

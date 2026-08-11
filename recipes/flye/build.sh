#!/bin/bash -euo

#zlib headers for minimap
sed -i.bak 's/CFLAGS=/CFLAGS+=/' lib/minimap2/Makefile
sed -i.bak 's/-O2/-O3/g' lib/minimap2/Makefile
sed -i.bak 's/INCLUDES=/INCLUDES+=/' lib/minimap2/Makefile
sed -i.bak 's/-O2/-O3/g' lib/samtools-1.9/Makefile
export CFLAGS="${CFLAGS} -O3 -L$PREFIX/lib"
export INCLUDES="-I$PREFIX/include"

rm -f lib/minimap2/*.bak
rm -f lib/samtools-1.9/*.bak

#zlib headers for flye binaries
export CXXFLAGS="$CXXFLAGS -O3 -I$PREFIX/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

#install_name_tool error fix
if [[ "$(uname -s)" == "Darwin" ]]; then
	export LDFLAGS="$LDFLAGS -headerpad_max_install_names"
fi

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' src/Makefile ;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' src/Makefile ;;
esac

#dynamic flag is needed for backtrace printing,
#but it seems it fails OSX build
sed -i.bak 's/-rdynamic//' src/Makefile

rm -f src/*.bak

${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

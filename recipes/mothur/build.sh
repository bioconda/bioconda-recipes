#!/bin/bash

export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"

if [[ "$(uname -s)" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -headerpad_max_install_names"
	sed -i.bak 's/-std=c++14/-std=c++14 -stdlib=libc++/' Makefile
 	sed -i.bak 's/-std=c++14/-std=c++14 -stdlib=libc++/' source/uchime_src/makefile
else
	### Dumping preset flags because they break the build process on linux
	# Linker flags
	unset LDFLAGS
	export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
fi

sed -i.bak 's/OPTIMIZE ?= yes/OPTIMIZE ?= no/' Makefile
rm -rf *.bak

### Compiling mothur
make clean

make CXX="${CXX}" -j"${CPU_COUNT}"

make install
install -v -m 0755 uchime "${PREFIX}/bin"

# Linking BLAST binaries to default location for mothur
mkdir -pv "${PREFIX}/bin/blast/bin"
ln -sf "${PREFIX}"/bin/{blastall,formatdb,megablast} "${PREFIX}/bin/blast/bin/"

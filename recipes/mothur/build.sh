#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
### Dumping preset flags because they break the build process on linux
# Linker flags
unset LDFLAGS
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's/-std=c++14/-std=c++14 -stdlib=libc++/' Makefile
  sed -i.bak 's/-std=c++14/-std=c++14 -stdlib=libc++/' source/uchime_src/makefile
  export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -headerpad_max_install_names"
fi

### Compiling mothur
make clean
make OPTIMIZE=no CXX="${CXX}" -j"${CPU_COUNT}"
make install
install -v -m 0755 uchime "${PREFIX}/bin"

# Linking BLAST binaries to default location for mothur
mkdir -pv "${PREFIX}/bin/blast/bin"
ln -sf "${PREFIX}"/bin/{blastall,formatdb,megablast} "${PREFIX}/bin/blast/bin/"

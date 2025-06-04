#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
### Dumping preset flags because they break the build process on linux
# Linker flags
unset LDFLAGS
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export TARGET_ARCH="$(uname -m)"

### Compiling mothur
make clean
make CXX="${CXX}" -j"${CPU_COUNT}"
make install
install -v -m 0755 uchime "${PREFIX}/bin"

# Linking BLAST binaries to default location for mothur
mkdir -pv "${PREFIX}/bin/blast/bin"
ln -sf "${PREFIX}"/bin/{blastall,formatdb,megablast} "${PREFIX}/bin/blast/bin/"

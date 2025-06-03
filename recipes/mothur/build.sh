#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
### Dumping preset flags because they break the build process on linux
# Linker flags
unset LDFLAGS
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
# Compiler flags
unset CXXFLAGS
export CXXFLAGS="${CXXFLAGS} -O3 -I."

sed -i.bak 's|-std=c++11|-std=c++14 -O3|' Makefile

### Compiling mothur
make clean
make CXX="${CXX}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
make install
install -v -m 0755 uchime ${PREFIX}/bin

# Linking BLAST binaries to default location for mothur
mkdir -pv "${PREFIX}"/bin/blast/bin/
ln -sf "${PREFIX}"/bin/{blastall,formatdb,megablast} "${PREFIX}"/bin/blast/bin/

#!/bin/bash
set -x -e

# Coils Dir
COILS_DIR="${PREFIX}/share/coils"
#list programs
COILS_PROGRAMS="coils-svr.pl coils-wrap.pl"

mkdir -p ${PREFIX}/bin
mkdir -p ${COILS_DIR}

# remove the precompilated one
rm -f ncoils-linux

sed -i.bak 's/^main(/int main(/' ncoils.c
sed -i.bak '1i#include <string.h>' ncoils.c
sed -i.bak '1i#include <string.h>' read_matrix.c
sed -i.bak -r 's/strncmp$([^,]+,[^,]+),([0-9]+)$/strncmp(\1,(size_t)\2)/g' read_matrix.c

#compile
${CC} -O3 -I. -I${PREFIX}/include -o ncoils-osf ncoils.c read_matrix.c -lm

# get the name of the ncoils program build
NCOILS=$(ls ncoils-*)

# info for debugging
ls -l

# copy tools in the bin
cp -rf * ${COILS_DIR}

# Add main tools
install -v -m 755 ${NCOILS} ${PREFIX}/bin

# Add extra programs
for PROGRAM in ${COILS_PROGRAMS}; do
	install -v -m 755 ${PROGRAM} ${PREFIX}/bin
done

# You then need to set an environment variable $COILSDIR to the coils folder
# These coils folder is installed as runtime deps, but the paths to it need to
# to reflect the current environment's $PREFIX/bin dir.
# export COILSDIR as ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d
echo "export COILSDIR=${COILS_DIR}" > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}.sh"

mkdir -p ${PREFIX}/etc/conda/deactivate.d
echo "unset COILSDIR" > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}.sh"

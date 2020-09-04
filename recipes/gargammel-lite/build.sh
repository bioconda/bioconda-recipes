#!/bin/bash

export CPATH=${PREFIX}/include

export CXXFLAGS="${CXXFLAGS} -std=c++14"
# Will be inbuilt to github repo in future
# sed -i.bak 's/make -C libgab/make -C libgab CXX=$(CC)/' Makefile
# sed -i.bak 's/make -C src/make -C src CXX=$(CC)/' Makefile
# sed -i.bak 's/CXXFLAGS =/CXXFLAGS +=/' src/Makefile
# sed -i.bak 's/LDFLAGS  =/LDFLAGS +=/' src/Makefile



cd "${SRC_DIR}"/gargammel || { echo "Folder ${SRC_DIR}/gargammel not found"; exit 1; }

sed -i.bak '1s/^/#include <stddef.h>\n/' "${SRC_DIR}"/gargammel/libgab/ReconsReferenceBAM.h


mkdir -p "${SRC_DIR}"/gargammel/bamtools/{lib,api,shared} 
ln -s "${PREFIX}"/lib/libbamtools* "${SRC_DIR}"/gargammel/bamtools/lib/
ln -s "${PREFIX}"/include/bamtools/api/* "${SRC_DIR}"/gargammel/bamtools/api/
ln -s "${PREFIX}"/include/bamtools/shared/* "${SRC_DIR}"/gargammel/bamtools/shared/
#ln -s "${PREFIX}"/include/bamtools/api "${SRC_DIR}"/gargammel/src/

## Following https://bioconda.github.io/contributor/troubleshooting.html#g-or-gcc-not-found
binaries=(src/fragSim src/deamSim src/adptSim)
# We list the targets explicitly to prevent the Makefile from downloading and
# building the external art_illumina.o dependency (added as a runtime
# requirement instead)
make CC="${CXX}" "${binaries[@]}"
mkdir -p "${PREFIX}"/bin
cp "${binaries[@]}" "${PREFIX}"/bin



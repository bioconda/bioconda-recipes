#!/bin/bash

export CPATH=${PREFIX}/include

cd "${SRC_DIR}"/gargammel || { echo "Folder ${SRC_DIR}/gargammel not found"; exit 1; }

# Avoid conflicts with C++20  
mv "${SRC_DIR}"/gargammel/libgab/gzstream/version "${SRC_DIR}"/gargammel/libgab/gzstream/version.txt

mkdir -p "${SRC_DIR}"/gargammel/bamtools/{lib,api,shared} 
ln -s "${PREFIX}"/lib/libbamtools* "${SRC_DIR}"/gargammel/bamtools/lib/
ln -s "${PREFIX}"/include/bamtools/api/* "${SRC_DIR}"/gargammel/bamtools/api/
ln -s "${PREFIX}"/include/bamtools/shared/* "${SRC_DIR}"/gargammel/bamtools/shared/

## Following https://bioconda.github.io/contributor/troubleshooting.html#g-or-gcc-not-found
binaries=(src/fragSim src/deamSim src/adptSim src/fasta2fastas)
# We list the targets explicitly to prevent the Makefile from downloading and
# building the external art_illumina.o dependency (added as a runtime
# requirement instead)
make CC="${CXX}" "${binaries[@]}"
mkdir -p "${PREFIX}"/bin
cp "${binaries[@]}" "${PREFIX}"/bin

# Fix hard-coded paths to external tools
sed \
  -e 's|$pathdir."/src/|"|' \
  -e 's|$pathdir."/art_src_MountRainier/|"|' \
  -e 's|^fileExists(.*);||' \
  -e 's|#!/usr/bin/perl|#!/usr/bin/env perl|' \
  gargammel.pl > "${PREFIX}"/bin/gargammel

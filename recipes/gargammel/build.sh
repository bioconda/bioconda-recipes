#!/bin/bash

export CPATH=${PREFIX}/include

# Will be inbuilt to github repo in future
sed -i.bak 's/make -C libgab/make -C libgab CXX=$(CC)/' Makefile
sed -i.bak 's/make -C src/make -C src CXX=$(CC)/' Makefile
sed -i.bak 's/CXXFLAGS =/CXXFLAGS +=/' src/Makefile
sed -i.bak 's/LDFLAGS  =/LDFLAGS +=/' src/Makefile

## Following https://bioconda.github.io/contributor/troubleshooting.html#g-or-gcc-not-found
binaries="src/fragSim src/deamSim src/adptSim src/fasta2fastas"
# We list the targets explicitly to prevent the Makefile from downloading and
# building the external art_illumina.o dependency (added as a runtime
# requirement instead)
make CC=$CXX ${binaries}

mkdir -p $PREFIX/bin
cp ${binaries} ${PREFIX}/bin

# Fix hard-coded paths to external tools
sed \
  -e 's|$pathdir."/src/|"|' \
  -e 's|$pathdir."/art_src_MountRainier/|"|' \
  -e 's|^fileExists(.*);||' \
  -e 's|#!/usr/bin/perl|#!/usr/bin/env perl|' \
  gargammel.pl > ${PREFIX}/bin/gargammel

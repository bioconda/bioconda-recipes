#!/bin/bash -e -x
cd ext
wget https://sourceforge.net/projects/bbmap/files/BBMap_38.08.tar.gz
tar -xzf BBMap_38.08.tar.gz
chmod +x ./bbmap/bbduk.sh

# make raxmlHPC executable
cd standard-raxml
make -f Makefile.SSE3.gcc
make -f Makefile.SSE3.PTHREADS.gcc
rm *.o
chmod +x raxmlHPC-PTHREADS-SSE3
chmod +x raxmlHPC-SSE3
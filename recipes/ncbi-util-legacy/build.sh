#!/bin/bash

# BIOCONDA_CC is patched in via 0001-Inject-our-CC.patch.
export BIOCONDA_CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
./ncbi/make/makedis.csh 

cp -rL ncbi/include/* "$PREFIX/include/"
cp ncbi/lib/* "$PREFIX/lib/"
cp ncbi/bin/* "$PREFIX/bin/"

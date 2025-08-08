#!/bin/bash
set -eu -o pipefail

# ## Binary install with wrappers

if [[ ${target_platform}  == "linux-aarch64" ]]; then
 	sed -i "14c CFLAGS=  \$(SFLAGS) -O3 -Xlinker -zmuldefs                    # release C-Compiler flags " Makefile
	sed -i "15c LFLAGS=  \$(SFLAGS) -O3 -Xlinker -zmuldefs                    # release linker flags" Makefile
	make 
else
	make CC="${CC}" LD="${CC}" CFLAGS=" -fcommon ${CFLAGS}" LFLAGS="${LDFLAGS}" all
fi

mkdir -p "${PREFIX}/bin"

mv svm_learn svm_classify "${PREFIX}/bin/"

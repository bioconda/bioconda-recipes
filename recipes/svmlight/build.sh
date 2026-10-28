#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

# ## Binary install with wrappers
if [[ "${target_platform}" == "linux-aarch64" ]]; then
 	sed -i "14c CFLAGS=  \$(SFLAGS) -O3 -Xlinker -zmuldefs                    # release C-Compiler flags " Makefile
	sed -i "15c LFLAGS=  \$(SFLAGS) -O3 -Xlinker -zmuldefs                    # release linker flags" Makefile
	make all CC="${CC}" LD="${CC}" CFLAGS="${CFLAGS} -fcommon" LFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
else
	make all CC="${CC}" LD="${CC}" CFLAGS="${CFLAGS} -fcommon" LFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
fi

install -v -m 0755 svm_learn svm_classify "${PREFIX}/bin"

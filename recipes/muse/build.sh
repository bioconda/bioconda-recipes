#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"

export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

# Print environment variables for debugging
echo "Print env variables"
echo "INCLUDES: ${INCLUDES}"
echo "LIBPATH: ${LIBPATH}"
echo "LDFLAGS: ${LDFLAGS}"
echo "CFLAGS: ${CFLAGS}"

make CC="${CC} -O3" CFLAGS="${CFLAGS}" CXX="${CXX}" LDFLAGS="${LDFLAGS}" \
	CXXFLAGS="${CXXFLAGS} -O3" \
	CPP="${CXX}" CPPFLAGS="${CXXFLAGS} -O3" \
	-j"${CPU_COUNT}"

# List the contents of the PREFIX directory to see where files are placed
echo "Listing contents of ${PREFIX}:"
ls -R "${PREFIX}"

chmod 0755 MuSE
cp -f MuSE "${PREFIX}/bin"

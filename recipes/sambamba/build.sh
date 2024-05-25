#!/bin/bash
set -eux

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [ $(uname) == "Darwin" ]; then
    export LDFLAGS="-headerpad_max_install_names ${LDFLAGS}"
fi

sed -e "/^CC=/d" Makefile > Makefile.new
mv Makefile.new Makefile

# Running this make target compiles an unoptimised binary so must be done prior to release compile
make test CC=${CC}

make CC=${CC} LIBRARY_PATH=${PREFIX}/lib prefix=${PREFIX}
make install prefix=${PREFIX}

# The binaries are versioned for some reason
mv ${PREFIX}/bin/sambamba-* ${PREFIX}/bin/sambamba

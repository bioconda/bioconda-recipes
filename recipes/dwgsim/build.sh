set -x -e -o pipefail
sed -i '4c\DFLAGS=         -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -D_USE_KNETFILE -DPACKAGE_VERSION=\\\\\\\"${PACKAGE_VERSION}\\\\\\\" -Dunreachable=dwgsim_unreachable' Makefile
sed -i 's/unreachable/dwgsim_unreachable/g' src/dwgsim.c
sed -i '8a CFLAGS += $(DFLAGS)' samtools/Makefile
make  CC="${CC}" CFLAGS="${CPPFLAGS} ${CFLAGS} -g -Wall -O3 ${LDFLAGS}" LIBCURSES=-lncurses

mkdir -p "${PREFIX}/bin"

cp dwgsim dwgsim_eval "${PREFIX}/bin/"

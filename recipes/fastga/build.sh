#!/bin/bash

mkdir -p ${PREFIX}/bin

export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include -L$PREFIX/lib -pthread"

# LDFLAGS is folded into CFLAGS on purpose. The Makefile never references $(LDFLAGS) -- every rule
# compiles and links in one step as `$(CC) $(CFLAGS) -o prog prog.c ... -lm -lz` -- so conda's
# linker flags reach the linker only by this route. On osx that includes
# -headerpad_max_install_names, without which conda-build's relocation step fails at:
#   install_name_tool: changing install names or rpaths can't be redone for ... bin/ALNshow
#   because larger updated load commands do not fit
make -j"${CPU_COUNT}" CC="${CC}" CFLAGS="${CFLAGS} ${LDFLAGS}"

install -v -m 0755 FastGA \
    FAtoGDB GIXmake ALNtoPAF ALNtoPSL \
    GDBshow GDBstat GIXshow ALNshow ALNplot \
    GDBtoFA GIXrm GIXcp GIXmv ALNchain ALNreset PAFtoALN PAFtoPSL \
    ONEview FastKS \
    ANOtoBED BEDtoANO ANOstat ANOshow $PREFIX/bin

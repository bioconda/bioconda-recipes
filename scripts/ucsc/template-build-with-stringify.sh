#!/bin/bash

set -xe

mkdir -p "${{PREFIX}}/bin"
export MACHTYPE=$(uname -m)
# kent ships lib/x86_64 and parasol/lib/x86_64 but no dir for any other arch,
# and "make libs" builds topLibs and hgLib in parallel, so hg/cgilib can ar into
# lib/${{MACHTYPE}} before lib/makefile has created it.
mkdir -p "kent/src/lib/${{MACHTYPE}}" "kent/src/parasol/lib/${{MACHTYPE}}"
export INCLUDE_PATH="${{PREFIX}}/include"
# htslib's Makefile assigns CPPFLAGS/CFLAGS outright, discarding the environment,
# so ${{PREFIX}}/include only reaches its compiles via gcc's own CPATH.
export CPATH="${{PREFIX}}/include"
export LIBRARY_PATH="${{PREFIX}}/lib"
export LDFLAGS="${{LDFLAGS}} -L${{PREFIX}}/lib"
export CFLAGS="${{CFLAGS}} -O3"
export COPT="${{COPT}} ${{CFLAGS}}"
export CPPFLAGS="${{CPPFLAGS}} -I${{PREFIX}}/include"
export CXXFLAGS="${{CXXFLAGS}} -O3"
export BINDIR=$(pwd)/bin
export L="${{LDFLAGS}}"
mkdir -p "${{BINDIR}}"
sed -i.bak 's|g++|$(CXX)|' kent/src/optimalLeaf/makefile
sed -i.bak 's|-g|-g -O3|' kent/src/optimalLeaf/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/optimalLeaf/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/jkOwnLib/makefile
sed -i.bak 's|ld|$(LD)|' kent/src/hg/lib/straw/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/lib/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/hg/cgilib/makefile
sed -i.bak 's|ar rcus|$(AR) rcs|' kent/src/hg/lib/makefile
rm -rf kent/src/optimalLeaf/*.bak
rm -rf kent/src/jkOwnLib/*.bak
rm -rf kent/src/hg/lib/straw/*.bak

# CFLAGS must stay out of the make argument list: a command-line variable
# overrides the makefile, so common.mk's "CFLAGS += -std=c11" would be dropped
# and kent's unprototyped declarations fail under the compiler's default -std.
(cd kent/src && make libs PTHREADLIB=1 CC="${{CC}}" CXX="${{CXX}}" -j"${{CPU_COUNT}}")
(cd kent/src/utils/stringify && make CC="${{CC}}" -j"${{CPU_COUNT}}")
(cd {program_source_dir} && make CC="${{CC}}" -j"${{CPU_COUNT}}")
cp bin/{program} "${{PREFIX}}/bin"
chmod 0755 "${{PREFIX}}/bin/{program}"

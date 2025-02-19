#!/bin/bash
set -ex

cp -rf "${RECIPE_DIR}/vcflib.pc.in" "${SRC_DIR}"

export M4="${BUILD_PREFIX}/bin/m4"
#export PATH="$(which zig):${PATH}"

export INCLUDES="-I${PREFIX}/include -I. -Ihtslib -Itabixpp -Iwfa2 -I\$(INC_DIR)"
export LIBPATH="-L${PREFIX}/lib -L. -Lhtslib -Ltabixpp -Lwfa2"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lhts -ltabixpp -lpthread -lz -lm -llzma -lbz2 -fopenmp -lwfa2"
export CXXFLAGS="${CXXFLAGS} -O3 -D_FILE_OFFSET_BITS=64 -I${PREFIX}/include"

sed -i.bak 's/CFFFLAGS:= -O3/CFFFLAGS=-O3 -D_FILE_OFFSET_BITS=64/' contrib/smithwaterman/Makefile
sed -i.bak 's/CFLAGS/CXXFLAGS/g' contrib/smithwaterman/Makefile

sed -i.bak 's/$</$< $(LDFLAGS)/g' contrib/smithwaterman/Makefile
sed -i.bak 's/ld/$(LD)/' contrib/smithwaterman/Makefile
sed -i.bak 's/gcc/$(CC) $(CFLAGS)/g' contrib/filevercmp/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' contrib/multichoose/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' contrib/intervaltree/Makefile

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [[ `uname` == "Darwin" ]]; then
	sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' contrib/smithwaterman/Makefile
	sed -i.bak 's/-std=c++0x/-std=c++17 -stdlib=libc++/g' contrib/intervaltree/Makefile
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -DWFA_GITMODULE=OFF"
else
        export CONFIG_ARGS="-DWFA_GITMODULE=ON"
fi

cmake -S . -B build \
	-DZIG=OFF -DOPENMP=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	"${CONFIG_ARGS}"

cmake --build build --target install -j "${CPU_COUNT}" -v

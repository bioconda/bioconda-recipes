#!/bin/bash
set -ex

cp -rf "${RECIPE_DIR}/vcflib.pc.in" "${SRC_DIR}"

export M4="${BUILD_PREFIX}/bin/m4"
export PATH="$(which zig):${PATH}"

export INCLUDES="-I${PREFIX}/include -I. -Ihtslib -Itabixpp -Iwfa2 -I\$(INC_DIR)"
export CXXFLAGS="${CXXFLAGS} -O3 -D_FILE_OFFSET_BITS=64 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

sed -i.bak 's/CFFFLAGS:= -O3/CFFFLAGS=-O3 -D_FILE_OFFSET_BITS=64/' contrib/smithwaterman/Makefile
sed -i.bak 's/CFLAGS/CXXFLAGS/g' contrib/smithwaterman/Makefile

sed -i.bak 's/$</$< $(LDFLAGS)/g' contrib/smithwaterman/Makefile
sed -i.bak 's/ld/$(LD)/' contrib/smithwaterman/Makefile
sed -i.bak 's/gcc/$(CC) $(CFLAGS)/g' contrib/filevercmp/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' contrib/multichoose/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' contrib/intervaltree/Makefile

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [[ `uname` == "Darwin" ]]; then
	export LIBPATH="-L${PREFIX}/lib -L. -Lhtslib -Ltabixpp -Lwfa2"
	export LDFLAGS="${LDFLAGS} -lhts -ltabixpp -lpthread -lz -lm -llzma -lbz2 -fopenmp -lwfa2"
	sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' contrib/smithwaterman/Makefile
	sed -i.bak 's/-std=c++0x/-std=c++17 -stdlib=libc++/g' contrib/intervaltree/Makefile
	rm -rf contrib/smithwaterman/*.bak
	rm -rf contrib/intervaltree/*.bak
	rm -rf contrib/filevercmp/*.bak
	rm -rf contrib/multichoose/*.bak
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -DWFA_GITMODULE=OFF"
else
	export LIBPATH="-L${PREFIX}/lib -L. -Lhtslib -Ltabixpp"
	export LDFLAGS="${LDFLAGS} -lhts -ltabixpp -lpthread -lz -lm -llzma -lbz2 -fopenmp"
 	export CONFIG_ARGS="-DWFA_GITMODULE=ON"
	rm -rf contrib/smithwaterman/*.bak
	rm -rf contrib/intervaltree/*.bak
	rm -rf contrib/filevercmp/*.bak
	rm -rf contrib/multichoose/*.bak
fi

cmake -S . -B build \
	-DZIG=ON -DOPENMP=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DPROFILING=ON \
	"${CONFIG_ARGS}"

cmake --build build --target install -j "${CPU_COUNT}"

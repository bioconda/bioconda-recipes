#!/bin/bash -ex

OS=$(uname)
ARCH=$(uname -m)

if [ "${OS}" == "Darwin" ] && [ "${ARCH}" == "x86_64" ]; then
	echo $(pwd)/zig-macos-x86_64-*
	export PATH="$(pwd)/zig-macos-x86_64-0.12.1:${PATH}"
elif [ "${OS}" == "Darwin" ] && [ "${ARCH}" == "arm64" ]; then
	echo $(pwd)/zig-macos-aarch64-*
	export PATH="$(pwd)/zig-macos-aarch64-0.12.1:${PATH}"
else
	echo $(pwd)/zig-linux-${ARCH}-*
	export PATH="$(pwd)/zig-linux-${ARCH}-0.12.1:${PATH}"
fi

#cd contrib && rm -rf WFA2-lib fastahack filevercmp fsom intervaltree libVCFH multichoose smithwaterman tabixpp

#git clone https://github.com/pjotrp/WFA2-lib.git && cd WFA2-lib
#git checkout d7b7ea99c8cd941c3e0feea359c217b36a6d43d1
#cd ..

#git clone https://github.com/ekg/fastahack.git && cd fastahack
#git checkout bb332654766c2177d6ec07941fe43facf8483b1d
#cd ..

#git clone https://github.com/ekg/filevercmp.git && cd filevercmp
#git checkout df20dcc4a2a772de56e804e8fbbcdef1ac068bbe
#cd ..

#git clone https://github.com/ekg/fsom.git && cd fsom
#git checkout 56695e1611d824cda97f08e932d25d08419170cd
#cd ..

#git clone https://github.com/ekg/intervaltree.git && cd intervaltree
#git checkout aa5937755000f1cd007402d03b6f7ce4427c5d21
#cd ..

#git clone https://github.com/edawson/libVCFH.git && cd libVCFH
#git checkout 44b6580639a216a484fd96de75a839091f25768a
#cd ..

#git clone https://github.com/vcflib/multichoose.git && cd multichoose
#git checkout 255192edd49cfe36557f7f4f0d2d6ee1c702ffbb
#cd ..

#git clone https://github.com/ekg/smithwaterman.git && cd smithwaterman
#git checkout 2610e259611ae4cde8f03c72499d28f03f6d38a7
#cd ..

#git clone --recursive https://github.com/vcflib/tabixpp.git && cd tabixpp
#git checkout ae5cdf846af85bd1d0e310c05e5c67b037f51a25
#cd ../../

export INCLUDES="-I${PREFIX}/include -I. -Ihtslib -Itabixpp -I\$(INC_DIR)"
export LIBPATH="-L${PREFIX}/lib -L. -Lhtslib -Ltabixpp"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lhts -ltabixpp -lpthread -lz -lm -llzma -lbz2 -fopenmp -lwfa2"
export CXXFLAGS="${CXXFLAGS} -O3 -D_FILE_OFFSET_BITS=64"

sed -i.bak 's/CFFFLAGS:= -O3/CFFFLAGS=-O3 -D_FILE_OFFSET_BITS=64 -std=c++0x/' contrib/smithwaterman/Makefile
sed -i.bak 's/CFLAGS/CXXFLAGS/g' contrib/smithwaterman/Makefile

sed -i.bak 's/$</$< $(LDFLAGS)/g' contrib/smithwaterman/Makefile
sed -i.bak 's/ld/$(LD)/' contrib/smithwaterman/Makefile
sed -i.bak 's/gcc/$(CC) $(CFLAGS)/g' contrib/filevercmp/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' contrib/multichoose/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' contrib/intervaltree/Makefile

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [ "${OS}" == "Darwin" ]; then
	sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' contrib/smithwaterman/Makefile
	sed -i.bak 's/-std=c++0x/-std=c++11 -stdlib=libc++/g' contrib/intervaltree/Makefile
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	# export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_ENABLE_CXX17_REMOVED_FEATURES"
	export CMAKE_EXTRA="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -Wno-dev"
else
        export CMAKE_EXTRA="-Wno-dev"
fi

pkg-config --list-all

cmake -S . -B build \
	-DZIG=ON -DOPENMP=ON -DWFA_GITMODULE=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" ${CMAKE_EXTRA}

cmake --build build/ --target install -j "${CPU_COUNT}" -v

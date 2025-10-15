#!/bin/bash
set -ex

cp -rf "${RECIPE_DIR}/vcflib.pc.in" "${SRC_DIR}"

sed -i.bak -e 's|1.0.13|1.0.14|' VERSION
sed -i.bak -e 's|-fPIC|-fPIC -Wno-int-conversion -Wno-deprecated-declarations -Wno-absolute-value -Wno-unused-comparison|' CMakeLists.txt
rm -rf *.bak

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDES="-I${PREFIX}/include -I. -Ihtslib -Itabixpp -Iwfa2 -I\$(INC_DIR)"
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -D_FILE_OFFSET_BITS=64"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" ]]; then
	sed -i.bak 's|HTSCODECS_VERSION_TEXT|HTSCODECS_VERSION|' contrib/tabixpp/htslib/htscodecs/htscodecs/htscodecs.c
	rm -rf contrib/tabixpp/htslib/htscodecs/htscodecs/*.bak
fi

if [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
	echo $(pwd)/zig-macos-x86_64-*
	export PATH="$(pwd)/zig-macos-x86_64-0.15.0-dev/lib:${PATH}"
	export PATH="$(pwd)/zig-macos-x86_64-0.15.0-dev:${PATH}"
	wget https://github.com/alexey-lysiuk/macos-sdk/releases/download/13.3/MacOSX13.3.tar.xz
	tar -xf MacOSX13.3.tar.xz
	cp -rH MacOSX13.3.sdk /Applications/Xcode_15.2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
	export SDKROOT="/Applications/Xcode_15.2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk"
	export MACOSX_DEPLOYMENT_TARGET=13.0
	export MACOSX_SDK_VERSION=13.0
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	echo $(pwd)/zig-macos-aarch64-*
	export PATH="$(pwd)/zig-macos-aarch64-0.15.0-dev/lib:${PATH}"
	export PATH="$(pwd)/zig-macos-aarch64-0.15.0-dev:${PATH}"
else
	echo $(pwd)/zig-linux-${ARCH}-*
	export PATH="$(pwd)/zig-linux-${ARCH}-0.15.0-dev/lib:${PATH}"
	export PATH="$(pwd)/zig-linux-${ARCH}-0.15.0-dev:${PATH}"
fi

sed -i.bak 's/CFFFLAGS:= -O3/CFFFLAGS=-O3 -D_FILE_OFFSET_BITS=64/' contrib/smithwaterman/Makefile
sed -i.bak 's/CFLAGS/CXXFLAGS/g' contrib/smithwaterman/Makefile
sed -i.bak 's/$</$< $(LDFLAGS)/g' contrib/smithwaterman/Makefile
sed -i.bak 's/ld/$(LD)/' contrib/smithwaterman/Makefile
sed -i.bak 's/gcc/$(CC) $(CFLAGS)/g' contrib/filevercmp/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' contrib/multichoose/Makefile
sed -i.bak 's/g++/$(CXX) $(CXXFLAGS)/g' contrib/intervaltree/Makefile

rm -rf contrib/filevercmp/*.bak
rm -rf contrib/multichoose/*.bak
rm -rf contrib/smithwaterman/*.bak
rm -rf contrib/intervaltree/*.bak

# MacOSX Build fix: https://github.com/chapmanb/homebrew-cbl/issues/14
if [[ "${OS}" == "Darwin" ]]; then
	export LIBPATH="-L${PREFIX}/lib -L. -Lhtslib -Ltabixpp -Lwfa2"
	export LDFLAGS="${LDFLAGS} -lhts -ltabixpp -pthread -lz -lm -llzma -lbz2 -lcurl -fopenmp -lwfa2"
	export CXXFLAGS="${CXXFLAGS}"
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER -DWFA_GITMODULE=OFF"
	sed -i.bak 's/LDFLAGS=-Wl,-s/LDFLAGS=/' contrib/smithwaterman/Makefile
	sed -i.bak 's/-std=c++0x/-std=c++17 -stdlib=libc++/g' contrib/intervaltree/Makefile
	rm -rf contrib/smithwaterman/*.bak
	rm -rf contrib/intervaltree/*.bak
else
	export LIBPATH="-L${PREFIX}/lib -L. -Lhtslib -Ltabixpp"
	export LDFLAGS="${LDFLAGS} -lhts -ltabixpp -pthread -lz -lm -llzma -lbz2 -lcurl -fopenmp"
 	export CONFIG_ARGS="-DWFA_GITMODULE=ON"
fi

if [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
	export CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_OSX_SYSROOT=/Applications/Xcode_15.2.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk"
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DOPENMP=ON -DPROFILING=ON -DZIG=ON -DBUILD_SHARED_LIBS=ON \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"

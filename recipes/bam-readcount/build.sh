#!/bin/bash -euo

mkdir -p "${PREFIX}/bin"

wget https://github.com/boostorg/boost/releases/download/boost-1.87.0/boost-1.87.0-cmake.tar.gz
mv boost-1.87.0-cmake.tar.gz vendor/boost-1.55-bamrc.tar.gz

sed -i.bak -e 's|2.8.3|3.10|' CMakeLists.txt
rm -rf *.bak
sed -i.bak -e 's|2.8|3.10|' cmake/BuildSamtools.cmake
sed -i.bak -e 's|2.8|3.10|' cmake/BuildBoost.cmake
rm -rf cmake/*.bak

# Needed for building utils dependency
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -pthread"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

OS=$(uname)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" ]]; then
        ln -sf ${CC} ${BUILD_PREFIX}/bin/clang
        ln -sf ${CXX} ${BUILD_PREFIX}/bin/clang++
        export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
        # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk for -D_LIBCPP_DISABLE_AVAILABILITY
        #export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
        export CFLAGS="${CFLAGS} -O3 -mmacosx-version-min=10.13 -fno-define-target-os-macros -Wno-unguarded-availability -Wno-deprecated-non-prototype -Wno-implicit-function-declaration"
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
        ln -sf ${CC} ${BUILD_PREFIX}/bin/gcc
        ln -sf ${CXX} ${BUILD_PREFIX}/bin/g++
	export CONFIG_ARGS=""
fi

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	wget https://github.com/alexey-lysiuk/macos-sdk/releases/download/13.3/MacOSX13.3.tar.xz
	tar -xf MacOSX13.3.tar.xz
	cp -rH MacOSX13.3.sdk /Applications/Xcode-15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
	wget https://github.com/tukaani-project/xz/archive/refs/tags/v5.6.4.tar.gz
	mv v5.6.4.tar.gz vendor/xz-5.2.4.tar.gz
	wget https://github.com/Mbed-TLS/mbedtls/releases/download/mbedtls-2.28.9/mbedtls-2.28.9.tar.bz2
	mv mbedtls-2.28.9.tar.bz2 vendor/mbedtls-2.16.4-apache.tgz
	export SDKROOT="/Applications/Xcode-15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk"
	export CONFIG_ARGS="${CONFIG_ARGS} -DCMAKE_OSX_SYSROOT=/Applications/Xcode-15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk"
	export MACOSX_DEPLOYMENT_TARGET=13.0
	export MACOSX_SDK_VERSION=13.0
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first -j 1 -v

install -v -m 0755 build/bin/bam-readcount "${PREFIX}/bin"

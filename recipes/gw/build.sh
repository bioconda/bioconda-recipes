#!/usr/bin/bash
set -e

ARCH=$(uname -m)
OS=$(uname -s)

# Use pre-built binarys for macOS and aarch64
if [ "$OS" = "Darwin" ]; then
    # MacOS
    SYSROOT_FLAGS=""
    CPPFLAGS="${CPPFLAGS}"
    LDFLAGS="${LDFLAGS} -L${PREFIX}"
    echo "Downloading pre-built skia"
    USE_GL=1 make prep > /dev/null 2>&1 

    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    prefix="${PREFIX}" \
        make -j ${CPU_COUNT}
    
    mkdir -p $PREFIX/bin
    cp gw $PREFIX/bin/gw
    cp -n .gw.ini $PREFIX/bin/.gw.ini
    chmod +x $PREFIX/bin/gw
    exit 0

elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    # Linux aarch64
    ls
    cd ./lib
    mkdir -p skia && cd skia
    curl -L -o skia.zip https://github.com/JetBrains/skia-pack/releases/download/m105-adda216f-4/Skia-m105-adda216f-4-linux-Release-arm64.zip
    unzip skia.zip
    # link expat from conda
    rm out/Release-linux-arm64/libexpat.a
    ls ./ && cd ../../
    
    SYSROOT_FLAGS="--sysroot=${BUILD_PREFIX}/${HOST}/sysroot"
    CPPFLAGS="${CPPFLAGS} -I${BUILD_PREFIX}/${HOST}/sysroot/usr/include ${SYSROOT_FLAGS}"
    LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -L${BUILD_PREFIX}/${HOST}/sysroot/usr/lib -L${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64 ${SYSROOT_FLAGS}"
    
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    prefix="${PREFIX}" \
        make -j ${CPU_COUNT}
    
    mkdir -p $PREFIX/bin
    cp gw $PREFIX/bin/gw
    cp -n .gw.ini $PREFIX/bin/.gw.ini
    chmod +x $PREFIX/bin/gw
    chmod +rw $PREFIX/bin/.gw.ini
    
    exit 0

fi

# Linux x86_64
ls

NAME=${PWD}/lib/skia
echo "Skia out folder is: $NAME"

cd ./lib
mkdir -p skia
mkdir -p build_skia && cd build_skia


# Set default flags
#EXTRA_CFLAGS=""
#EXTRA_LDFLAGS=""
EXTRA_CFLAGS="extra_cflags=[\"-mavx2\", \"-mfma\", \"-mavx512f\", \"-mavx512dq\", \"-msse4.2\", \"-mpopcnt\", \"-frtti\", $INCLUDE]"
EXTRA_LDFLAGS="extra_ldflags=[\"-mavx2\", \"-mfma\", \"-mavx512f\", \"-mavx512dq\", $LIB]"
INCLUDE="\"-I$PREFIX/include\", \"-I$PREFIX/include/freetype2\", \"-I$PREFIX/include/libpng16\""
LIB="\"-L${PREFIX}/lib\""

# Architecture-specific flags
# if [ "$ARCH" = "x86_64" ]; then
    # Old glibc so cant use depot_tools
    # EXTRA_CFLAGS="extra_cflags=[\"-mavx2\", \"-mfma\", \"-mavx512f\", \"-mavx512dq\", \"-msse4.2\", \"-mpopcnt\", \"-frtti\", $INCLUDE]"
    # EXTRA_LDFLAGS="extra_ldflags=[\"-mavx2\", \"-mfma\", \"-mavx512f\", \"-mavx512dq\", $LIB]"
    
# elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
#     EXTRA_CFLAGS="extra_cflags=[\"-frtti\", $INCLUDE]"
#     EXTRA_LDFLAGS="extra_ldflags=[ $LIB]"
    #EXTRA_CFLAGS="extra_cflags=[\"-march=armv8-a+crc+crypto\", \"-frtti\", $INCLUDE]"
    #EXTRA_LDFLAGS="extra_ldflags=[\"-march=armv8-a+crc+crypto\", $LIB]"

# fi

EXTRA_ARGS="skia_use_egl=true skia_use_gl=true skia_use_x11=true"

echo "Architecture: $ARCH"
echo "Operating System: $OS"
echo "Extra C flags: $EXTRA_CFLAGS"
echo "Extra LD flags: $EXTRA_LDFLAGS"
echo "Extra arguments: $EXTRA_ARGS"
export PATH="${CONDA_PREFIX}/bin:$PATH"

# Check system build tools available
echo "Using gn from: $(which gn)"
echo "Using ninja from: $(which ninja)"

echo "Cloning skia"
git clone https://skia.googlesource.com/skia.git

cd skia
VERSION=m93
git checkout origin/chrome/${VERSION}
echo "Checked out Skia version: ${VERSION}"
echo "Using python3: " $(which python3)

# Patch gn to map aarch64 to arm64
sed -i.bak 's/cpu = {/cpu = {"aarch64": "arm64", /g' bin/fetch-gn

python3 tools/git-sync-deps

REL=Release

echo "STARTING SKIA BUILD"

# Generate build files
gn gen out/${REL} --args="is_official_build=true \
    skia_use_system_icu=true \
    skia_use_system_zlib=true \
    skia_use_system_expat=true \
    skia_use_system_libjpeg_turbo=true \
    skia_use_system_libpng=true \
    skia_use_system_libwebp=false \
    skia_use_system_harfbuzz=false \
    skia_pdf_subset_harfbuzz=true \
    skia_enable_skottie=false \
    skia_use_dng_sdk=false \
    target_cpu=\"${ARCH}\" \
    ${EXTRA_CFLAGS} \
    ${EXTRA_LDFLAGS} \
    cc=\"clang\" \
    cxx=\"clang++\" \
    ${EXTRA_ARGS}"
gn args out/${REL} --list
ninja -C out/${REL}

echo "------------SKIA BUILD FINISHED---------------"
pwd
ls

mkdir -p ${NAME}/out/${REL}
mkdir -p ${NAME}/third_party/externals

cp -rf out/${REL}/* ${NAME}/out/${REL}
cp -rf include ${NAME}
cp -rf modules ${NAME}
cp -rf src ${NAME}

# clean up
cd ${NAME}
cd ../

pwd
rm -rf build_skia
cd ../
echo "----------DONE PREPARING SKIA-------------"
pwd

#if [[ "$OSTYPE" != "darwin"* ]]; then
#  sed -i 's/-lEGL -lGLESv2/-lEGL -lGLESv2 -lGL -lGLX/' Makefile
  #sed -i 's/GLFW_EGL_CONTEXT_API/GLFW_NATIVE_CONTEXT_API/' src/plot_manager.cpp
#fi

# Link icu component libs
sed -i.bak 's/-licu/-licuuc -licui18n -licudata -lexpat/g' Makefile

SYSROOT_FLAGS="--sysroot=${BUILD_PREFIX}/${HOST}/sysroot"
CPPFLAGS="${CPPFLAGS} -I${BUILD_PREFIX}/${HOST}/sysroot/usr/include ${SYSROOT_FLAGS}"
LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -L${BUILD_PREFIX}/${HOST}/sysroot/usr/lib -L${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64 ${SYSROOT_FLAGS}"

CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY" \
CPPFLAGS="${CPPFLAGS}" \
LDFLAGS="${LDFLAGS}" \
prefix="${PREFIX}" \
    make -j ${CPU_COUNT}

mkdir -p $PREFIX/bin
cp gw $PREFIX/bin/gw
cp -n .gw.ini $PREFIX/bin/.gw.ini
chmod +x $PREFIX/bin/gw
chmod +rw $PREFIX/bin/.gw.ini

#!/bin/bash -euo

unamestr=`uname`

# Download and build zlib-ng in compatibility mode
echo "=== Downloading and building zlib-ng in compatibility mode ==="

# Create a temporary directory for zlib-ng
ZLIB_NG_DIR="${SRC_DIR}/temp-zlib-ng"
mkdir -p "${ZLIB_NG_DIR}"
cd "${ZLIB_NG_DIR}"

# Download zlib-ng
curl -L https://github.com/zlib-ng/zlib-ng/archive/refs/tags/2.3.2.tar.gz -o zlib-ng.tar.gz
tar -xzf zlib-ng.tar.gz
cd zlib-ng-2.3.2

# Build and install to PREFIX
mkdir build && cd build
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DZLIB_COMPAT=ON \
    -DZLIB_ENABLE_TESTS=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    ..

make -j${CPU_COUNT}
make install

# Verify installation
echo "=== Verifying zlib-ng installation ==="
ls -la ${PREFIX}/include/ | grep zlib
ls -la ${PREFIX}/lib/ | grep -E "libz\."

if [ ! -f "${PREFIX}/include/zlib.h" ]; then
    echo "ERROR: zlib.h not found after zlib-ng installation!"
    exit 1
fi

# Clean up
cd "${SRC_DIR}"
rm -rf "${ZLIB_NG_DIR}"

## START ADDED to deal with zlib-ng strangeness on linux
# Check if we have zlib-ng headers
ls -la $PREFIX/include/ | grep -i zlib
find $PREFIX -name "*zlib*"
## END ADDED to deal with zlib-ng strangeness on linux


if [ "$unamestr" == 'Darwin' ];
then
  if [[ $(uname -m) == 'x86_64' ]]; then
    echo "OSX x86-64: attempting to fix broken (old) SDK behavior"
    export CFLAGS="${CFLAGS} -D_LIBCPP_HAS_NO_C11_ALIGNED_ALLOC"
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_HAS_NO_C11_ALIGNED_ALLOC"
  fi
  export MACOSX_DEPLOYMENT_TARGET=10.15
  export MACOSX_SDK_VERSION=10.15
  export CFLAGS="${CFLAGS} -fcommon -D_LIBCPP_DISABLE_AVAILABILITY -fno-define-target-os-macros"
  export CXXFLAGS="${CXXFLAGS} -fcommon -D_LIBCPP_DISABLE_AVAILABILITY"
else 
  export CFLAGS="${CFLAGS} -fcommon"
  export CXXFLAGS="${CXXFLAGS} -fcommon"
   # It's dumb and absurd that the KMC build can't find the bzip2 header <bzlib.h>
  export C_INCLUDE_PATH="${C_INCLUDE_PATH}:${PREFIX}/include"
  export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH}:${PREFIX}/include"
fi

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true 
export CARGO_HOME="$(pwd)/.cargo"
export NUM_JOBS=1
export CARGO_BUILD_JOBS=1

# Access the zlib-ng installed by conda and copy it
if [ "$unamestr" == 'Darwin' ]; then
  LIBZ_STATIC_LIB=$PREFIX/lib/libz.a
  if [ -f $LIBZ_STATIC_LIB ]; then
     echo "File $LIBZ_STATIC_LIB exists, copying to libz-ng.a"
     cp $LIBZ_STATIC_LIB $PREFIX/lib/libz-ng.a
  else
      LIBZ_STATIC_LIB=$PREFIX/lib64/libz.a
      if [ -f $LIBZ_STATIC_LIB ]; then
       echo "File $LIBZ_STATIC_LIB exists, copying to libz-ng.a"
       cp $LIBZ_STATIC_LIB $PREFIX/lib64/libz-ng.a
     fi
  fi
fi

if [ "$unamestr" == 'Darwin' ];
then

# build statically linked binary with Rust
CONDA_BUILD=TRUE RUSTFLAGS="-C link-args=-Wl,-undefined,dynamic_lookup" RUST_BACKTRACE=1 cargo install -v -v -j 1 --verbose --root $PREFIX --path .

else
export CFLAGS="${CFLAGS} --param ggc-min-expand=20 --param ggc-min-heapsize=8192"
export CXXFLAGS="${CXXFLAGS} --param ggc-min-expand=20 --param ggc-min-heapsize=8192"
export CMAKE_POLICY_VERSION_MINIMUM=3.5
# build statically linked binary with Rust
CMAKE_POLICY_VERSION_MINIMUM=3.5 CONDA_BUILD=TRUE RUSTFLAGS="-L $PREFIX/lib64" RUST_BACKTRACE=1 cargo install -v -v -j 1 --verbose --root $PREFIX --path .

fi

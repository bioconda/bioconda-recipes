#!/bin/bash -e

cd $SRC_DIR/mtsv/ext

# apparently the HOME variable isn't set correctly, and circle ci output indicates the following as the home directory
export HOME="/Users/distiller"
# To solve error: linker `cc` from https://users.rust-lang.org/t/compiling-rust-package-using-cc-linker-from-a-custom-location/15795
export CC=$GCC
# build statically linked binary with Rust
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="${CC}"
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib RUST_BACKTRACE=1 cargo build --release --verbose
$GXX -std=c++11 -pthread ../mtsv_prep/taxidtool.cpp -o mtsv-db-build

binaries="\
mtsv-build \
mtsv-readprep \
mtsv-binner \
mtsv-chunk \
mtsv-collapse \
mtsv-signature \
mtsv-tree-build \
"

for i in $binaries; do cp $SRC_DIR/mtsv/ext/target/release/$i $PREFIX/bin; done

cd $SRC_DIR
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

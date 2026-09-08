
export LIBCLANG_PATH="$BUILD_PREFIX/lib"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --path . --root $PREFIX
UMI_TOOLS=$(find $(pwd) -type f -executable -name "umi-tools-rs")
install -Dm755 "$UMI_TOOLS" $PREFIX/bin/umi-tools-rs
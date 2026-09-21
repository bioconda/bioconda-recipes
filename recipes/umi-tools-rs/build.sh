
export LIBCLANG_PATH="$BUILD_PREFIX/lib"
export RELEASE_VERSION="$PKG_VERSION"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --no-track --path . --root "$PREFIX"

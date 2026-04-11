tar -xzf ${name}-${version}.crate
cd ${name}-${version}
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --no-track --root "$PREFIX" --path .

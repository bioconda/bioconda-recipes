#!/bin/bash -euo

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"
# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

if [[ -n "$OSX_ARCH" ]]; then
	# Set this so that it doesn't fail with open ssl errors
	export RUSTFLAGS="-C link-arg=-undefined -C link-arg=dynamic_lookup"
fi

sed -i.bak 's|"0.39"|"0.50.0"|' Cargo.toml
rm -rf *.bak

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install --no-track --verbose --path . --root "${PREFIX}"

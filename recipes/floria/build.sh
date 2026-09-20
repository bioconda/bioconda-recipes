#!/bin/bash -euo

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

if [[ `uname -s` == "Darwin" ]]; then
	export CFLAGS="${CFLAGS} -Wno-int-conversion -Wno-implicit-function-declaration"
fi

case $(uname -m) in
    aarch64)
	export CONFIG_ARGS="--features=neon"
	;;
    arm64)
	export CONFIG_ARGS="--features=neon"
	;;
    x86_64)
	export CONFIG_ARGS=""
	;;
esac

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --path . --root "${PREFIX}" --verbose --no-track "${CONFIG_ARGS}"

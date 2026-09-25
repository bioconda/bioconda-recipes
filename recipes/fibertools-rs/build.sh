#!/bin/bash -e
#
# Set the desitnation for the libtorch files
#

export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

#
# install package
#
HOME=$(pwd)
pushd ${PREFIX}

# remove cpu specifc cargo flags
pushd ${HOME}
sed -i.bak 's/native/generic/g' .cargo/config.toml >tmp
mv tmp .cargo/config.toml
popd

RUST_BACKTRACE=full
RUSTFLAGS="-C linker=${CC}"
cargo install -v --locked --no-track --verbose \
    --root "${PREFIX}" --path "${HOME}"
popd

echo "Done building ft" 1>&2

#
# test install
#
ft --help

#
# test install on data
#
pushd ${HOME}
ft m6a -v tests/data/all.bam /dev/null
popd

exit 0

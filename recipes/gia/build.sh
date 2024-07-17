#!/bin/bash -e

#
# TODO: Remove the following export when pinning is updated and we use
#       {{ compiler('rust') }} in the recipe.
export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo"
export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

#
# install package
#
HOME=$(pwd)
pushd ${PREFIX}

# remove cpu specifc cargo flags
pushd ${HOME}
sed 's/native/generic/g' .cargo/config.toml >tmp
mv tmp .cargo/config.toml
popd

cargo install --no-track --verbose \
    --root "${PREFIX}" --path "${HOME}"
popd

echo "Done building gia" 1>&2

#
# test install
#
gia help

exit 0

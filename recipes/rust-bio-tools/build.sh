#!/bin/bash -e


1	#!/bin/bash
2	if [ `uname` == Darwin ]; then
3		export MACOSX_DEPLOYMENT_TARGET=10.14
4	fi

# TODO: Remove the following export when pinning is updated and we use
#       {{ compiler('rust') }} in the recipe.
export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo"

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

cargo install --no-track --verbose --root "${PREFIX}" --path .

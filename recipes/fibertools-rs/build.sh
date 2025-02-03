#!/bin/bash -e
#
# Set the desitnation for the libtorch files
#

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

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

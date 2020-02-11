#!/bin/bash -euo

set -x
set -o xtrace -o nounset -o pipefail -o errexit

SOEXT=so

# taken from yacrd recipe, see: https://github.com/bioconda/bioconda-recipes/blob/2b02c3db6400499d910bc5f297d23cb20c9db4f8/recipes/yacrd/build.sh
if [ "$(uname)" == "Darwin" ]; then

    # apparently the HOME variable isn't set correctly
    export HOME="/Users/distiller"

    # according to https://github.com/rust-lang/cargo/issues/2422#issuecomment-198458960 removing circle ci default configuration solves cargo trouble downloading crates
    git config --global --unset url.ssh://git@github.com.insteadOf || true

    SOEXT=dylib
fi

export RUSTC_WRAPPER=$(which sccache)

$PYTHON -m pip install --no-deps --ignore-installed -vv .

cp include/sourmash.h ${PREFIX}/include/

cargo build --release
cp target/release/libsourmash.a ${PREFIX}/lib/
cp target/release/libsourmash.${SOEXT} ${PREFIX}/lib/

mkdir -p ${PREFIX}/lib/pkgconfig
cat > ${PREFIX}/lib/pkgconfig/sourmash.pc <<"EOF"
prefix=/usr/local
exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: sourmash
Description: Compute MinHash signatures for nucleotide (DNA/RNA) and protein sequences.
Version: 0.4.0
Cflags: -I${includedir}
Libs: -L${libdir} -lsourmash
EOF

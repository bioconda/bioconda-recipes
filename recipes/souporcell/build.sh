#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon -I${PREFIX}/include"

# Include scripts
cp -f stan_consensus.pickle $PREFIX/bin/stan_consensus.pickle
cp -f *.py $PREFIX/bin

# Build statically linked binary with Rust
RUST_BACKTRACE=1
for pkg in souporcell troublet; do
  pushd ${pkg}
    cargo-bundle-licenses -f yaml -o ${pkg}-THIRDPARTY.yml
    cargo build --release
  
    # Scripts expect the binary located in the following folder
    mkdir -p ${PREFIX}/bin/${pkg}/target/release
    cp target/$(rustc -vV | grep host | awk '{print $2}')/release/${pkg} ${PREFIX}/bin/${pkg}/target/release/${pkg}
  popd
done

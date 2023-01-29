#!/bin/bash -euo

unamestr=`uname`

if [ "$unamestr" == 'Darwin' ];
then
  export MACOSX_DEPLOYMENT_TARGET=10.15
  export CFLAGS="${CFLAGS} -fcommon -D_LIBCPP_DISABLE_AVAILABILITY -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
  export CXXFLAGS="${CXXFLAGS} -fcommon -D_LIBCPP_DISABLE_AVAILABILITY -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
  export CPPFLAGS=$(echo "${CPPFLAGS}" | sed 's|10\.9|10.15|g')
  export CMAKE_ARGS=$(echo "${CMAKE_ARGS}" | sed 's|10\.9|10.15|g')
else 
  export CFLAGS="${CFLAGS} -fcommon"
  export CXXFLAGS="${CXXFLAGS} -fcommon"
fi

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true 
export CARGO_HOME="$(pwd)/.cargo"

if [ "$unamestr" == 'Darwin' ];
then

cat >$CARGO_HOME/config.toml << EOF
[build]
# symbols won't be available until runtime
rustflags = ["-C", "link-args=-Wl,-undefined,dynamic_lookup"]
EOF

fi

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --root $PREFIX --path .

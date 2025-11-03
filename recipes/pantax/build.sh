#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    cp -rf $SRC_DIR $PREFIX
else
    cd ${SRC_DIR}/scripts
    chmod +x pantax data_preprocessing pantax_utils
    cp ${SRC_DIR}/scripts/pantax ${SRC_DIR}/scripts/data_preprocessing ${SRC_DIR}/scripts/pantax_utils ${PREFIX}/bin
    cp ${SRC_DIR}/scripts/*py ${PREFIX}/bin

    export GUROBI_HOME="$(cd ${SRC_DIR}/gurobi1103/linux64 && pwd)"
    cp -rf "$GUROBI_HOME/lib/libgurobi110.so" "$PREFIX/lib"
    
    cd ${SRC_DIR}/pantaxr
    # export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"
    # export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
    # export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
    # export LIBCLANG_PATH=$PREFIX/lib
    # export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
    RUST_BACKTRACE=1 RUSTFLAGS="-C link-args=-Wl,-rpath,${PREFIX}/lib" cargo build --release
    cp target/*/release/pantaxr ${PREFIX}/bin/pantaxr
fi

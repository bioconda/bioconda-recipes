#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
    cp -rf $SRC_DIR $PREFIX
else
    cd ${SRC_DIR}/scripts
    chmod +x pantax-utils pantax-rg
    cp ${SRC_DIR}/scripts/pantax-utils ${SRC_DIR}/scripts/pantax-rg ${PREFIX}/bin
    cp ${SRC_DIR}/scripts/*py ${PREFIX}/bin

    export GUROBI_HOME="$(cd ${SRC_DIR}/gurobi1103/linux64 && pwd)"
    cp -rf "$GUROBI_HOME/lib/libgurobi110.so" "$PREFIX/lib"
    
    cd ${SRC_DIR}/pantax
    RUST_BACKTRACE=1 RUSTFLAGS="-C link-args=-Wl,-rpath,${PREFIX}/lib" cargo build --release
    RUST_BACKTRACE=1 RUSTFLAGS="-C link-args=-Wl,-rpath,${PREFIX}/lib" cargo build -r --features free --no-default-features --bin pantax-free
    RUST_BACKTRACE=1 RUSTFLAGS="-C link-args=-Wl,-rpath,${PREFIX}/lib" cargo build -r --features gb --no-default-features --bin pantax-gb
    cp target/*/release/pantax ${PREFIX}/bin/pantax
    cp target/*/release/pantax-free ${PREFIX}/bin/pantax-free
    cp target/*/release/pantax-gb ${PREFIX}/bin/pantax-gb
    cp target/*/release/pantax-md ${PREFIX}/bin/pantax-md
fi

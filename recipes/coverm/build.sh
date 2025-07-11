#!/bin/bash -e

if ! grep -r 'let canonical_ptr = canonical' /root/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/rust-htslib-0.44.1/src/bam/record.rs; then
    sed -i '2318i\            let canonical_ptr = canonical as *mut i8 as *mut u8;' /root/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/rust-htslib-0.44.1/src/bam/record.rs
    sed -i '2324s/.*/                canonical_ptr,/' /root/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/rust-htslib-0.44.1/src/bam/record.rs
fi
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \

cargo build --release || true

catalogue=$BUILD_PREFIX/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/rust-htslib-0.44.1/src/bam/record.rs

if [ -f "$catalogue" ]; then
    if ! grep -r 'let canonical_ptr = canonical' $catalogue; then
        sed -i '2318i\            let canonical_ptr = canonical as *mut i8 as *mut u8;' $catalogue
        sed -i '2325s/.*/                canonical_ptr,/' $catalogue
    fi
fi
cargo build --release
cargo install --root $PREFIX


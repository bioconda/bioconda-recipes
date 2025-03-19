#!/bin/bash -e


if grep -r 'let canonical_ptr = canonical' /root/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/rust-htslib-0.44.1/src/bam/record.rs; then
    echo "存在该行代码"
else
    echo "不存在该行代码"
    sed -i '2318i\            let canonical_ptr = canonical as *mut i8 as *mut u8;' /root/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/rust-htslib-0.44.1/src/bam/record.rs
    sed -i '2324s/.*/                canonical_ptr,/' /root/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/rust-htslib-0.44.1/src/bam/record.rs
fi


# Build statically linked binary with Rust
C_INCLUDE_PATH=$PREFIX/include \
LIBRARY_PATH=$PREFIX/lib \
cargo build --release

# Install the binaries
cargo install --root $PREFIX

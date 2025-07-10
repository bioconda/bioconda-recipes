#!/bin/bash -euo

set -xe

# On macOS, AGC makefile has strict version checks
if [[ $(uname) == "Darwin" ]]; then
    # Set PLATFORM for ARM64 Macs as AGC expects
    if [[ $(uname -m) == "arm64" ]]; then
        export PLATFORM=arm8
    fi
    
    # AGC expects standard compiler names, not conda's prefixed ones
    # Create wrapper scripts that call the conda compilers
    mkdir -p $BUILD_PREFIX/bin
    
    # Create wrapper for gcc that calls clang
    cat > $BUILD_PREFIX/bin/gcc << EOF
#!/bin/bash
exec $CC "\$@"
EOF
    chmod +x $BUILD_PREFIX/bin/gcc
    
    # Create wrapper for g++ that calls clang++
    cat > $BUILD_PREFIX/bin/g++ << EOF
#!/bin/bash
exec $CXX "\$@"
EOF
    chmod +x $BUILD_PREFIX/bin/g++
    
    # Add to PATH
    export PATH="$BUILD_PREFIX/bin:$PATH"
    
    # Force AGC to use our wrappers
    export CC=gcc
    export CXX=g++
    
    # Set make command for macOS (AGC looks for gmake on macOS)
    export MAKE=make
else
    # Linux: Create symlinks for standard compiler names
    mkdir -p $BUILD_PREFIX/bin
    ln -sf $CC $BUILD_PREFIX/bin/gcc
    ln -sf $CXX $BUILD_PREFIX/bin/g++
    
    # Ensure the symlinks are in PATH
    export PATH="$BUILD_PREFIX/bin:$PATH"
    
    # Export standard names
    export CC=gcc
    export CXX=g++
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install -v --no-track --path . --root "${PREFIX}"

#!/bin/bash

# Exit on error
set -e

if [ -z "$PREFIX" ]; then
    echo "PREFIX environment variable not set"
    exit 1
fi

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# Clean any previous builds
make clean || true

if ! make; then
    echo "Build failed"
    exit 1
fi

if [ ! -f gzrecover ]; then
    echo "Build did not produce gzrecover binary"
    exit 1
fi

chmod 755 gzrecover

if ! mkdir -p "$PREFIX/bin"; then
    echo "Failed to create bin directory"
    exit 1
fi

# Remove existing installation if present
rm -f "$PREFIX/bin/gzrecover"

if ! cp gzrecover "$PREFIX/bin/"; then
    echo "Failed to install gzrecover"
    exit 1
fi

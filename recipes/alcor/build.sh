#!/bin/bash

# Stop the script if any command returns a non-zero exit status
set -e

# Print each command as it is executed
set -x

export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

mkdir -p "$PREFIX/bin"

# Run cleanup tasks if the script is interrupted
trap 'echo "Interrupted, cleaning up..."' INT

# Set up the build environment
cd src

# Build and install the package
cmake -S . -B . -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_C_COMPILER="$CC" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}" \
	.
cmake --build .

# Copy the executable to the bin directory
install -v -m 0755 "$SRC_DIR/src/AlcoR" "$PREFIX/bin"

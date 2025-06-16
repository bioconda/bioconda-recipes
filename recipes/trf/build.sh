#!/bin/bash
set -euo pipefail

echo "Starting build Process."
mkdir -p build
mkdir -p "${PREFIX}/bin"

echo "Compiling TRF with platform-aware toolchain."

case "${target_platform}" in
    osx-64*|osx-arm64*)
        EXTRA_LDFLAGS=""
        ;;
    linux-64*|linux-aarch64*)
        EXTRA_LDFLAGS="-lm"
        ;;
    *)
        echo "Unsupported platform: ${target_platform}"
        exit 1
        ;;
esac

${CC} ${CFLAGS} -O3 \
    ${CPPFLAGS} -DUNIXCONSOLE -DVERSION=\"4.10.0-rc.1\" \
    -I${PREFIX}/include \
    -o build/trf \
    src/trf.c \
    ${LDFLAGS} ${EXTRA_LDFLAGS}

echo "Installing binary to \$PREFIX/bin..."
cp build/trf "${PREFIX}/bin/trf"
echo "'trf' build and installation complete."

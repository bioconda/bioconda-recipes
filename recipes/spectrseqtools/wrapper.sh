#!/bin/sh

# needed to detect mono on macos
export DYLD_FALLBACK_LIBRARY_PATH="$CONDA_PREFIX/lib:$DYLD_FALLBACK_LIBRARY_PATH"
exec python -m spectrseqtools.cli "$@"

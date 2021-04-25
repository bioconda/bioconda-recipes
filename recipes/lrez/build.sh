#!/bin/bash

make -j"${CPU_COUNT}" \
    BUILD_BINDIR='$(BUILD_PREFIX)' \
    BUILD_LIBDIR='$(BUILD_PREFIX)'
make install \
    BUILD_BINDIR='$(BUILD_PREFIX)' \
    BUILD_LIBDIR='$(BUILD_PREFIX)'

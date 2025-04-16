#!/bin/bash

export ROOT="$(pwd)"

INSTALL=off ./linux_build-egl.bash

cd "$ROOT/build/make_debug"
make install

cd "$ROOT/build/make_release"
make install

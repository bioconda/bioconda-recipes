#!/bin/bash

meson setup build --prefix ${PREFIX}
cd build
ninja
ninja install

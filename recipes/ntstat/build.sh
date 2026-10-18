#!/usr/bin/env bash

CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

meson setup --buildtype release --prefix=$PREFIX build
meson install -C build

#!/usr/bin/env bash

meson setup --buildtype release --prefix=$PREFIX build
meson install -C build

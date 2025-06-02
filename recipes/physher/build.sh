#!/bin/bash

set -xe

cmake -S . -B build -DBUILD_CPP_WRAPPER=on -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build build/ --target install -j ${CPU_COUNT}
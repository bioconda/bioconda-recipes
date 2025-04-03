#!/usr/bin/env bash

set -xe

make -j"${CPU_COUNT}"

make install prefix=$PREFIX

#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

install -m 0755 bin/baysor/bin/baysor $PREFIX/bin/baysor

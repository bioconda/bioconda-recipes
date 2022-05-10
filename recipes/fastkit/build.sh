#!/bin/sh

mkdir -p $PREFIX/bin

# Install executables
install -C packages/fastkit/bin/* $PREFIX/bin

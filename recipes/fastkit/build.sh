#!/bin/sh

mkdir -p $PREFIX/bin

# Install executables
install -C bin/* $PREFIX/bin

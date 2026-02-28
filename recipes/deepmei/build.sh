#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin
cp -r * $PREFIX/bin/
chmod +x $PREFIX/bin/*

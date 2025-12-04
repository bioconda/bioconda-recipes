#!/usr/bin/env bash

mkdir -p $PREFIX/bin/
cp -r src/* $PREFIX/bin
chmod +x $PREFIX/bin/mmlong2

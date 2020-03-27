#!/bin/bash

set -x -e

mkdir -p $PREFIX/bin
chmod +x hitac
cp hitac $PREFIX/bin

#!/bin/bash

# fail on all errors
set -e

mkdir -p "$PREFIX/libexec" "$PREFIX/bin"

# clean and build Canu into libexec dir
( cd src; make clean TARGET_DIR=$PREFIX/libexec && make TARGET_DIR=$PREFIX/libexec )

# Link all executable files to bin
find $PREFIX/libexec -type f -perm +111 -exec ln -s {} $PREFIX/bin \;


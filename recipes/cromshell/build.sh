#!/bin/bash

set -eu -o pipefail

mkdir -p $PREFIX/bin
ls -l
cp cromshell $PREFIX/bin/

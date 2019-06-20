#!/bin/bash

set -eu -o pipefail

mkdir -p $PREFIX/bin
cp cromshell $PREFIX/bin/

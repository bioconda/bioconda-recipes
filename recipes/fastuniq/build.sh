#!/bin/bash
set -eu -o pipefail

cd source
make
cp fastuniq $PREFIX/bin

#!/usr/bin/env bash
set -eux -o pipefail

bin/barrnap --updatedb
make -C build clean
cp -av * "$PREFIX/"

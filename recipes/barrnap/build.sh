#!/usr/bin/env bash
set -eux -o pipefail

bin/barrnap --updatedb
make -C buld clean
cp -av * "$PREFIX/"

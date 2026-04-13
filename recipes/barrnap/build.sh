#!/usr/bin/env bash
set -eux -o pipefail

bin/barrnap --updatedb
cp -av * "$PREFIX/"

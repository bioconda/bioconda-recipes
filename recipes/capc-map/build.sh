#!/bin/bash

set -eu -o pipefail

./configure --prefix=$PREFIX
make
make install PREFIX=$PREFIX

pip install . --no-deps --ignore-installed --no-cache-dir -vvv


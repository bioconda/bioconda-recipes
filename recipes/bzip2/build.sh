#!/bin/bash

set -euf -o pipefail

make
make PREFIX=$PREFIX install


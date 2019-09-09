#!/bin/bash
set -eu -o pipefail

make

# No make install, README says just move/copy binary
mv sabre $PREFIX/bin/

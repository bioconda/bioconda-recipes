#!/bin/bash
set -x
set -e

echo "PATH is $PATH"
# The annotations directory needs to be uploaded by the user.
# It is too big to be uploaded automatically.
# test -d $PREFIX/annotations
slncky --help > /dev/null 2>&1

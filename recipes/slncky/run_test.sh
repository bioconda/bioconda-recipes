#!/bin/bash
set -x
set -e

slncky --help 2>&1
# The annotations directory needs to be uploaded by the user.
# It is too big to be uploaded automatically.
# test -d $PREFIX/annotations

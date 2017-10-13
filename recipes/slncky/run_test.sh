#!/bin/bash
set -x
set -e

slncky --help 2>&1
test -d $PREFIX/annotations

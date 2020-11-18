#!/bin/sh
nimble build -y --verbose
cp strling $PREFIX/bin/strling
# TODO: copy python scripts

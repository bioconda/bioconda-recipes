#!/bin/sh
set -e

mkdir -p "${PREFIX}/bin"
mv bin/* "${PREFIX}/bin/"

exit 0

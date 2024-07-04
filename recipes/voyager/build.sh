#!/bin/bash
mkdir -p "$PREFIX/bin"

# tar -xzf voyager-*.tar.gz

cp voyager-cli $PREFIX/bin/
cp voyager-build-cli $PREFIX/bin/
cp voyager-combine-cli $PREFIX/bin/
cp voyager-debug-index $PREFIX/bin/

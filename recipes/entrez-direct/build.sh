#!/bin/bash

# Keep track of the process
set -uex

mkdir bin nobin
# Don't install these most bespoke scripts
mv custom-* idx-* pm-* xy-* nobin
# Move ordinary scripts into a subdirectory for convenience
mv $(find * -type d -prune -o -print | sed '/^[A-Z]/d;/[.]pdf$/d;/[.]pem$/d;/[.]py$/d;/conda/d;/build/d') bin

mkdir -p $PREFIX/bin
(cd cmd && sh -ex ./build.sh $PREFIX/bin)
(cd extern && sh -ex ./build.sh $PREFIX/bin)

# Ensure conda-build can tidy up this compiler cache tree
test -d gopath && chmod -R u+wX gopath

mkdir -p $PREFIX/bin/data $PREFIX/bin/help
install -m 644 data/* $PREFIX/bin/data
install -m 644 help/* $PREFIX/bin/help

install -m 755 bin/* $PREFIX/bin

echo "Check for additional scripts to be installed to .../bin"
ls

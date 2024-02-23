#!/bin/bash

set -ex

grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'

autoreconf -i
./configure --prefix="${PREFIX}" --enable-sse
make -j 2
make install

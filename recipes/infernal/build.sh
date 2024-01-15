#!/bin/bash

set -ex

NAME=infernal
VERSION=1.1.5
TAG="${NAME}-${VERSION}"

grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'

git clone --depth 1 -b $TAG https://github.com/EddyRivasLab/hmmer
git clone --depth 1 -b $TAG https://github.com/EddyRivasLab/easel

autoreconf -i
./configure --prefix=$PREFIX
make -j 2
make check
make install

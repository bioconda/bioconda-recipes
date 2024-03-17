#!/bin/bash

autoreconf -i
./configure
make
mv bin/jellyfish bin/seed-jellyfish
cp bin/seed-jellyfish ${PREFIX}/bin

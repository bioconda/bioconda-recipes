#!/bin/bash

grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'


./configure --prefix=$PREFIX
make -j 2
make check
make install

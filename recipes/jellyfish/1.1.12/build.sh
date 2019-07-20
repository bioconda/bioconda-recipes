#!/bin/bash

autoreconf -fi
./configure --prefix=$PREFIX
make
make install

ls -l ${PREFIX}/lib/

mv ${PREFIX}/include/jellyfish-1.1.12/jellyfish ${PREFIX}/lib/
rmdir ${PREFIX}/include/jellyfish-1.1.12/

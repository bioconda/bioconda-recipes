#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

./bootstrap.sh
./configure --with-boost=${PREFIX} --prefix=${PREFIX}
make metamaps

mkdir -p $PREFIX/bin
cp -f metamaps $PREFIX/bin/

# Copy dependencies to bin dir until there is a better solution
chmod a+x *.pl
grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'
cp *.pl *.R $PREFIX/bin/
cp -r perlLib $PREFIX/bin/
cp -r util $PREFIX/bin/

#!/bin/bash

# seems like BusyBox v1.36.1's readlink does not have a -m option 
sed -e "s/ -m \$filename/ -f \$filename/" Misc/Applications/lib/foldGrammars/Utils.pm

make -j ${CPU_COUNT} PREFIX=$PREFIX CC=$CC -C Misc/Applications/RapidShapes all
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/RapidShapes install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod 755 $PREFIX/bin/RapidShapes*

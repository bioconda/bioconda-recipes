#!/bin/bash -euo

make PREFIX=$PREFIX CC=$CC -C Misc/Applications/pKiss all
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/pKiss install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod 755 $PREFIX/bin/pKiss* $PREFIX/bin/addRNA*

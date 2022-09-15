#!/bin/sh
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/pKiss all
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/pKiss install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod +x $PREFIX/bin/pKiss* $PREFIX/bin/addRNA*

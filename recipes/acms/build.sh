#!/bin/sh
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/aCMs all
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/aCMs install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod +x $PREFIX/bin/RNA*

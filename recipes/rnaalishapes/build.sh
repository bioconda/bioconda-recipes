#!/bin/sh
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/RNAalishapes all
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/RNAalishapes install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod +x $PREFIX/bin/RNA*

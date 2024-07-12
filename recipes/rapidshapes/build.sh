#!/bin/sh
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/RapidShapes all
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/RapidShapes install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod +x $PREFIX/bin/RNA*

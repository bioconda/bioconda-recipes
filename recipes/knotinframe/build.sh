#!/bin/sh
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/Knotinframe all
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/Knotinframe install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod +x $PREFIX/bin/knotinframe* $PREFIX/bin/addRNA*

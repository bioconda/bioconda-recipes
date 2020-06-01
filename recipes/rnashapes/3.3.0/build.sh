#!/bin/sh
cat $PREFIX/share/gapc/config_linux-gnu.mf || True
cat Misc/Applications/RNAshapes/makefile || True
echo $CC || True
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/RNAshapes mfe_nodangle
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/RNAshapes install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod +x $PREFIX/bin/*

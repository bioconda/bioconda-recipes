#!/bin/sh
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/RNAshapes mfe_nodangle
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/RNAshapes install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod +x $PREFIX/bin/*

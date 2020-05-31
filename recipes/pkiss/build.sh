#!/bin/sh
sed -i $PREFIX/share/gapc/config_linux-gnu.mf "s/^CXX = /#CXX = /"
sed -i $PREFIX/share/gapc/config_linux-gnu.mf "s/^CC = /#CC = /"
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/pKiss all
make CC=$CC -C Misc/Applications/pKiss install-program
make CC=$CC -C Misc/Applications/lib install
chmod +x $PREFIX/bin/*

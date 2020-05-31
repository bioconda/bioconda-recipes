#!/bin/sh
sed "s/^CXX = /#CXX = /" -i $PREFIX/share/gapc/config_linux-gnu.mf
sed "s/^CC = /#CC = /" -i $PREFIX/share/gapc/config_linux-gnu.mf 
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/pKiss all
make CC=$CC -C Misc/Applications/pKiss install-program
make CC=$CC -C Misc/Applications/lib install
chmod +x $PREFIX/bin/*

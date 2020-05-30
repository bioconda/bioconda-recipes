#!/bin/sh
which -a g++ || g++ --version || env
make PREFIX=$PREFIX CC=$CXX -C Misc/Applications/pKiss all
make -C Misc/Applications/pKiss install-program
make -C Misc/Applications/lib install
chmod +x $PREFIX/bin/*

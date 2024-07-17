#!/bin/bash

# flag glasgow-ext is no longer supported in OSX
sed -e "s/ -fglasgow-exts / /g" Misc/Applications/aCMs  Misc/Applications/makefile

make -j ${CPU_COUNT} PREFIX=$PREFIX CC=$CC -C Misc/Applications/aCMs all
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/aCMs install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod 755 $PREFIX/bin/acmbuild*

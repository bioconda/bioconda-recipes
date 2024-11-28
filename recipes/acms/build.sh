#!/bin/bash

make -j ${CPU_COUNT} PREFIX=$PREFIX CC=$CC -C Misc/Applications/aCMs all
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/aCMs install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod 755 $PREFIX/bin/acmbuild*

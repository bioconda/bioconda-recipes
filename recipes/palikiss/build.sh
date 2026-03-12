#!/bin/bash
make -j ${CPU_COUNT} PREFIX=$PREFIX CC=$CC -C Misc/Applications/pAliKiss all
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/pAliKiss install-program
make PREFIX=$PREFIX CC=$CC -C Misc/Applications/lib install
chmod +x $PREFIX/bin/pAliKiss*
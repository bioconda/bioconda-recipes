#!/bin/bash

python setup.py config -c

# ensure SEPP's configuration file is at the correct location ...
echo "${PREFIX}/share/sepp/.sepp" > home.path
mkdir -p $PREFIX/share/sepp/.sepp
# ... and holds correct path names
mv -v default.main.config $PREFIX/share/sepp/.sepp/main.config
patch $PREFIX/share/sepp/.sepp/main.config < relocate.main.config.patch

python setup.py install --prefix=${PREFIX}

# copy bundled binaries into $PREFIX/bin/
mkdir -p $PREFIX/bin/
cp `cat $SRC_DIR/.sepp/main.config | grep "^path" -m 1 | cut -d "=" -f 2 | xargs dirname`/* $PREFIX/bin/

# configure run-sepp.sh for qiime2 fragment-insertion
mv -v sepp-package/run-sepp.sh $PREFIX/bin/run-sepp.sh
patch $PREFIX/bin/run-sepp.sh < relocate.run-sepp.sh.patch

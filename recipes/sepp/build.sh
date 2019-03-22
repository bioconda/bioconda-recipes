#!/bin/bash

# ignore sepp's own dependencie of dendropy, since this is already installed via conda.
# Due to being a noarch package, setup.py is unable to see it and would otherwise try to install,
# which fails due to conda build restrictions.
patch setup.py < nodeps.setup.py.patch

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

# copy files for tests to shared conda directory
mkdir -p $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/input_fragments.fasta $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/reference_alignment_tiny.fasta $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/reference_phylogeny_tiny.nwk $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/RAxML_info-reference-gg-raxml-bl.info $PREFIX/share/sepp/ref/

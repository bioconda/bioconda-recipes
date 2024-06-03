#!/bin/bash
set -ex
python setup.py config -c
python setup.py upp -c

# ensure SEPP's configuration file is at the correct location ...
echo "${PREFIX}/share/sepp/sepp" > home.path
# ensure directory is created ... ($SP_DIR = Python's site-packages location, see https://docs.conda.io/projects/conda-build/en/stable/user-guide/environment-variables.html#environment-variables-set-during-the-build-process)
mkdir -p $SP_DIR/
# ... before we copy content into it
cp -rv home.path $SP_DIR/
mkdir -p $PREFIX/share/sepp/sepp
# ... and holds correct path names
mv -v sepp-package/sepp/default.main.config $PREFIX/share/sepp/sepp/main.config
# copy upp config, as it's still needed
cp ./.sepp/upp.config $PREFIX/share/sepp/sepp/upp.config
# replace $PREFIX with /opt/anaconda1anaconda2anaconda3 for later replacement of concrete build PREFIX
# note: can't apply a patch here, as upp.config is not part of upstream but gets generated during python setup
if [ $unamestr == 'Linux' ];
then
	sed -i 's@'"$PREFIX"'@/opt/anaconda1anaconda2anaconda3@g' $PREFIX/share/sepp/sepp/upp.config
elif [ $unamestr == 'Darwin' ];
then
	gsed -i 's@'"$PREFIX"'@/opt/anaconda1anaconda2anaconda3@g' $PREFIX/share/sepp/sepp/upp.config
fi

$PYTHON -m pip install . --ignore-installed --no-deps -vv

# copy bundled binaries, but hmmer which should be provided by conda, into $PREFIX/bin/
mkdir -p $PREFIX/bin/
cp `cat $SRC_DIR/.sepp/main.config | grep "^path" -m 1 | grep -v "hmm" | cut -d "=" -f 2 | xargs dirname`/* $PREFIX/bin/
cp `cat $SRC_DIR/.sepp/upp.config | grep "^path" -m 1 | grep -v "hmm" | cut -d "=" -f 2 | xargs dirname`/* $PREFIX/bin/

# configure run-sepp.sh for qiime2 fragment-insertion
mv -v sepp-package/run-sepp.sh $PREFIX/bin/run-sepp.sh

# copy files for tests to shared conda directory
mkdir -p $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/input_fragments.fasta $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/reference_alignment_tiny.fasta $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/reference_phylogeny_tiny.nwk $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/RAxML_info-reference-gg-raxml-bl.info $PREFIX/share/sepp/ref/

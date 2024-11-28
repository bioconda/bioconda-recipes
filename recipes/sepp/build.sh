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
sed -i 's@'"$PREFIX"'@/opt/anaconda1anaconda2anaconda3@g' $PREFIX/share/sepp/sepp/upp.config

if [ "$(uname)" == "Linux" ];
then
	wget https://github.com/matsen/pplacer/releases/download/v1.1.alpha17/pplacer-linux-v1.1.alpha17.zip
	unzip pplacer-linux-v1.1.alpha17.zip
	mv pplacer-Linux-v1.1.alpha17/{pplacer,guppy} $PREFIX/bin/
elif [ "$(uname)" == "Darwin" ];
then
	wget https://github.com/matsen/pplacer/releases/download/v1.1.alpha17/pplacer-Darwin-v1.1.alpha17.zip
	unzip pplacer-Darwin-v1.1.alpha17.zip
	mv pplacer-Darwin-v1.1.alpha17-6-g5cecf99/{pplacer,guppy} $PREFIX/bin/
fi

$PYTHON -m pip install . --ignore-installed --no-deps -vv

# copy bundled binaries, but hmmer which should be provided by conda (and pplacer as long as bioconda PR https://github.com/bioconda/bioconda-recipes/pull/52395 is not merged), into $PREFIX/bin/
mkdir -p $PREFIX/bin/
cp -v `cat $SRC_DIR/.sepp/main.config | grep "^path" | grep -v "hmm" | grep -v "pplacer" | grep -v "guppy" | cut -d "=" -f 2` $PREFIX/bin/
cp -v `cat $SRC_DIR/.sepp/upp.config | grep "^path" | grep -v "hmm" | grep -v "pplacer" | grep -v "guppy" | grep -v "run_pasta" | cut -d "=" -f 2` $PREFIX/bin/

# as long as upstream does not merge my PR https://github.com/smirarab/sepp/pull/138, I manually obtain the fixed seppJsonMerger.jar here
wget https://raw.githubusercontent.com/jlab/sepp/refs/heads/fix_merger/tools/merge/seppJsonMerger.jar
mv seppJsonMerger.jar $PREFIX/bin/

# configure run-sepp.sh for qiime2 fragment-insertion
mv -v sepp-package/run-sepp.sh $PREFIX/bin/run-sepp.sh

# copy files for tests to shared conda directory
mkdir -p $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/input_fragments.fasta $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/reference_alignment_tiny.fasta $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/reference_phylogeny_tiny.nwk $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/RAxML_info-reference-gg-raxml-bl.info $PREFIX/share/sepp/ref/

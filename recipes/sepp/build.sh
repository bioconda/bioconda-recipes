#!/bin/bash
set -ex

pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
config_sepp -c
config_upp -c

# copy bundled binaries, but hmmer, pplacer and guppy which should be provided by conda, into $PREFIX/bin/
# looks like only binary remaining after the exclusions is now a .jar file
mkdir -p $PREFIX/bin/
cp -v `cat $SRC_DIR/.sepp/main.config | grep "^path" | grep -v "hmm" | grep -v "pplacer" | grep -v "guppy" | cut -d "=" -f 2` $PREFIX/bin/
cp -v `cat $SRC_DIR/.sepp/upp.config | grep "^path" | grep -v "hmm" | grep -v "pplacer" | grep -v "guppy" | grep -v "run_pasta" | cut -d "=" -f 2` $PREFIX/bin/

# make the run-sepp.sh script part of the deployment
cp -v $SRC_DIR/sepp-package/run-sepp.sh $PREFIX/bin/run-sepp.sh

# SEPP's mechanism to identify the location of binaries is a bit complicated.
# Paths to binaries like hmmsearch, pplacer, ... can be configured in a file
# called main.config, which itself is expected to be found in a sub-directory
# structure of the sources. Location of sources is recorded as file content
# of a "home.path" file, in the Python package of sepp.
# Since source files themselves don't get copied in conda build, we need to
#   a) copy according file into a sub-directory ($PREFIX/share/) that get
#      delibvered through conda
#   b) determine the correct path as the content of the "home.path" file
#   c) store the "home.path" file in the correct directory

# === a ===: create sub-directory
mkdir -p $PREFIX/share/sepp/sepp
# copy SEPP config
cp -v $SRC_DIR/sepp-package/sepp/default.main.config $PREFIX/share/sepp/sepp/main.config
# copy UPP config (same as SEPP, but with run_pasta added)
cp -v $SRC_DIR/sepp-package/sepp/default.main.config $PREFIX/share/sepp/sepp/upp.config
echo -e "\n[pasta]\npath=run_pasta.py" >> $PREFIX/share/sepp/sepp/upp.config

# === b+c ===: determine correct path for source sub-directory in deployment and store in home.path
echo "${PREFIX}/share/sepp/sepp" > $SP_DIR/sepp-*.dist-info/home.path

# copy files for tests to shared conda directory
mkdir -p $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/input_fragments.fasta $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/reference_alignment_tiny.fasta $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/reference_phylogeny_tiny.nwk $PREFIX/share/sepp/ref/
cp -v test/unittest/data/q2-fragment-insertion/RAxML_info-reference-gg-raxml-bl.info $PREFIX/share/sepp/ref/

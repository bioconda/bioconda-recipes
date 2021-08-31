#!/bin/bash

# fix zlib error
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

MATAM_HOME=$PREFIX/opt/matam-$PKG_VERSION
mkdir -p $MATAM_HOME/{bin,scripts}

git submodule update --init --recursive -- componentsearch ovgraphbuild

# componentsearch
# use make CC=$CXX instead of make to avoid g++ not found
cd $SRC_DIR/componentsearch && make CC=$CXX
COMPONENT_SEARCH=$MATAM_HOME/componentsearch
mkdir $COMPONENT_SEARCH
cp $SRC_DIR/componentsearch/componentsearch $COMPONENT_SEARCH

# ovgraphbuild
OVGRAPHBUILD_BUILD_DIR=$SRC_DIR/ovgraphbuild/build
mkdir $OVGRAPHBUILD_BUILD_DIR && cd $OVGRAPHBUILD_BUILD_DIR && cmake .. -G"CodeBlocks - Unix Makefiles" && make
OVGRAPHBUILD=$MATAM_HOME/ovgraphbuild/bin
mkdir -p $OVGRAPHBUILD
cp $SRC_DIR/ovgraphbuild/bin/ovgraphbuild $OVGRAPHBUILD

# copy matam scripts
cp $SRC_DIR/scripts/*.py $MATAM_HOME/scripts
cp $SRC_DIR/index_default_ssu_rrna_db.py $MATAM_HOME

# copy tests dir
cp -r $SRC_DIR/tests/ $MATAM_HOME/tests

# copy examples dir
cp -r $SRC_DIR/examples/ $MATAM_HOME/examples

# make a symlink as matam do
ln -s $MATAM_HOME/scripts/matam_* $MATAM_HOME/bin/

# makes binaries available in the environment
mkdir -p $PREFIX/bin
ln -s $MATAM_HOME/index_default_ssu_rrna_db.py $PREFIX/bin/
ln -s $MATAM_HOME/bin/matam_* $PREFIX/bin/


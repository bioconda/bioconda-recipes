#!/bin/bash

# it's unclear if it's possible to inject compilers into swi-prolog
mkdir -p ${PREFIX}/bin
ln -s $CC ${PREFIX}/bin/gcc

#to fix problems with zlib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PREFIX}/lib
export JAVA_HOME=${PREFIX}

# skip ruby tests
export TRAVIS=1
mkdir -p test/tmp
mkdir -p test/results

# gem install cassiopee
sed -i 's;externalinterfacewithspacer/2,;;g' prolog/logol.pl
sed -i 's;getPosition_pos/3,;;g' prolog/logol.pl
sed -i 's;externalinterface/2,;;g' prolog/logol.pl
sed -i 's;#!/usr/bin/ruby;#!/usr/bin/env ruby;g' tools/cassiopeeSearch.rb

#sed -i 's;INFO;DEBUG;g' log4j.properties
#ant -f build.xml setup compile_swi_exe create-jar
ant -f build.xml dist_swi
mkdir -p $PREFIX/lib/logol
cp -r * $PREFIX/lib/logol/
cd $PREFIX/bin && ln -s ../lib/logol/LogolExec.sh
cd $PREFIX/bin && ln -s ../lib/logol/LogolMultiExec.sh
unlink ${PREFIX}/bin/gcc

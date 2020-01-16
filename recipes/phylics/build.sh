#!/bin/bash

# The build system fetches our .tar.gz from github and puts us
# in its "root" directory
#WD=$(pwd)
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/src
cp phylics/local/src/*.py $PREFIX/src
for p in $PREFIX/src/*py; do
	NOPATH=$(basename -- "$p")
	NOEXT="${NOPATH%.*}"
	ln -s $p $PREFIX/bin/$NOEXT;
done

# tell Marilisa to call ginkgo as ginkgo.sh direclty, remove bins from git repo
cd phylics/local/src/ginkgo/genomes/scripts && make
cd phylics/local/src/ginkgo/scripts && make
cp phylics/local/src/ginkgo/cli/ginkgo.sh $PREFIX/bin/
cp -r phylics/local/src/ginkgo/* $PREFIX/

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

# tell Marilisa to call ginkgo as ginkgo.sh direclty
cp phylics/local/src/ginkgo/ginkgo.sh $PREFIX/bin/
cp -r phylics/local/src/ginkgo $PREFIX/

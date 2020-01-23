#!/bin/bash

# The build system fetches our .tar.gz from github and puts us
# in its "root" directory
WD=$(pwd)
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/src
cp phylics/local/src/*.py $PREFIX/src
for p in $PREFIX/src/*py; do
	NOPATH=$(basename -- "$p")
	NOEXT="${NOPATH%.*}"
	ln -s $p $PREFIX/bin/$NOEXT;
done

cd phylics/local/src/ginkgo/genomes/scripts && make 2> /dev/null || echo "build 1"
cd $WD
cd phylics/local/src/ginkgo/scripts && make 2> /dev/null || echo "build 2"
cd $WD
cp phylics/local/src/ginkgo/cli/ginkgo.sh $PREFIX/bin/
cp -r phylics/local/src/ginkgo/scripts $PREFIX/
cp -r phylics/local/src/ginkgo/cli $PREFIX/
cp -r phylics/local/src/ginkgo/genomes $PREFIX/

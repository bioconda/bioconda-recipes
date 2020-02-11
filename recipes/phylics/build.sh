#!/bin/bash

# The build system fetches our .tar.gz from github and puts us
# in its "root" directory

echo "$RPATH"

WD=$(pwd)


mkdir -p $PREFIX/bin
mkdir -p $PREFIX/src
cp phylics/local/src/*.py $PREFIX/src
for p in $PREFIX/src/*py; do
	NOPATH=$(basename -- "$p")
	NOEXT="${NOPATH%.*}"
	ln -s $p $PREFIX/bin/$NOEXT;
done


cp phylics/local/src/ginkgo/cli/ginkgo.sh $PREFIX/bin/
cp phylics/local/src/ginkgo/Makefile $PREFIX/
cp -r phylics/local/src/ginkgo/scripts $PREFIX/
cp -r phylics/local/src/ginkgo/cli $PREFIX/
cp -r phylics/local/src/ginkgo/genomes $PREFIX/

#compile ginkgo
cd $PREFIX
make 2> /dev/null

cd $PREFIX/genomes/scripts
make 2> /dev/null


cd phylics/local/src/ginkgo/genomes/scripts && make 2> /dev/null
cd $WD

cd phylics/local/src/ginkgo/ && make 2> /dev/null
cd $WD




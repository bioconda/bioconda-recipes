#!/bin/bash

# The build system fetches our .tar.gz from github and puts us
# in its "root" directory
WD=$(pwd)
mkdir -p $PREFIX/bin
cp $WD/phylics/local/src/*.py $PREFIX/bin
for p in $PREFIX/bin/*py; do
	NOPATH=$(basename -- "$p")
	NOEXT="${NOPATH%.*}"
	ln -s $p $PREFIX/bin/$NOEXT;
done
# and for gingko? its not in the repo now
#ginkgo_path = os.path.join(BIN_DIR,"ginkgo", "cli", "ginkgo.sh")
#data@rotpunkt:~/work/phylics$ grep -i ROOT_DIR PhyliCS-1.0.0/local/src/*.py
# NEED TO FIX:
#PhyliCS-1.0.0/local/src/constants.py:ROOT_DIR = '/home/mmontemurro/PhyliCS'
#PhyliCS-1.0.0/local/src/constants.py:BIN_DIR = ROOT_DIR + '/local/bin'
#PhyliCS-1.0.0/local/src/constants.py:SRC_DIR = ROOT_DIR + '/local/src'

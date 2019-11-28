#!/bin/sh

# Create bin folder
mkdir -p $PREFIX/bin

# On Linux, PHAST requires CLAPACK to be installed with the default directory structure.
# CLAPACK conda package does not follow this structure and it's easier to
# download and compile CLAPACK from source
if [[ "$OSTYPE" != "darwin"* ]]; then
	wget http://www.netlib.org/clapack/clapack.tgz
	tar -xf clapack.tgz
	cd CLAPACK-3.2.1
	cp make.inc.example make.inc && make CC=$CC f2clib && make CC=$CC blaslib && make CC=$CC lib
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
	cd src
	make CC=$CC
else
	# On linux, PHAST needs a path to Clapack libraries at compile time
	cd ../src
	make CC=$CC CLAPACKPATH=$SRC_DIR/CLAPACK-3.2.1
fi

# PHAST builds multiple binaries
cd ..
chmod +x bin/*
mv bin/* $PREFIX/bin

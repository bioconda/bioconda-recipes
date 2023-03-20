#!/bin/bash

# install viralcomplete from source
(
	git clone \
		https://github.com/ablab/viralComplete \
		$SRC_DIR/viralComplete
	cd $SRC_DIR/viralComplete || exit 1
	git checkout -f db9ffa7
	mv bin/viralcomplete $PREFIX/bin/
	mv blast_db $PREFIX/
	mv data $PREFIX/
)

# install viralflye
mv viralflye $SP_DIR/
mv viralFlye.py $PREFIX/bin/

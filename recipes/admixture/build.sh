#!/bin/bash

mkdir -p $PREFIX/bin

if [[ $(uname -s) == Darwin ]]; then
	cp mac/admixture_macosx-1.3.0/admixture $PREFIX/bin/
else
	cp linux/admixture $PREFIX/bin/
fi


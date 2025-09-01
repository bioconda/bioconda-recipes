#!/bin/bash

mkdir -p ${PREFIX}/bin
if [[ $target_platform == 'linux-aarch64' ]]; then
	sed -i.bak '3s/-msse//g' Makefile	
fi

make CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} -fopenmp -DOMP ${LDFLAGS}"
cp bin/* ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/*
cp -r databases ${PREFIX}
cp -r example ${PREFIX}

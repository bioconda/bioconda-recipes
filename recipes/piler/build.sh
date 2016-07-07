#! /bin/bash

mkdir -p $PREFIX/bin
if [ -d "piler" ] # osx platform
then 
	cd piler
	make
	cp piler $PREFIX/bin
else  # linux 
	make
	cp piler2 $PREFIX/bin
fi

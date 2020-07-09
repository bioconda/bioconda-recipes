#!/bin/bash
./build_jar.sh $PREFIX/bin/iris.jar
mkdir -p $PREFIX/bin
cp jasmine jasmine.jar $PREFIX/bin 

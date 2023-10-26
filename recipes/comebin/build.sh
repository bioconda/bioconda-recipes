#!/usr/bin/evn bash

mkdir -p $PREFIX/bin 
cp -r COMEBIN $PREFIX/bin/
cp -r auxiliary $PREFIX/bin/
cp bin/run_comebin.sh $PREFIX/bin/
chmod a+x $PREFIX/bin/run_combin.sh


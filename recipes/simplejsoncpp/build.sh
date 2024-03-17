#!/bin/bash

mkdir -p ${PREFIX}/include/simplejsoncpp/
mkdir -p ${PREFIX}/lib/simplejsoncpp/

make \
  CXX="${CXX}" \
  all
cp obj/*a   $PREFIX/lib/simplejsoncpp/
cp src/*\.h $PREFIX/include/simplejsoncpp/
cd ..


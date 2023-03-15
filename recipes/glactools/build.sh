#!/bin/bash

make CC="${CC} CXX="${CXX}"
mkdir ${PREFIX}/bin/
cp glactools ${PREFIX}/bin/


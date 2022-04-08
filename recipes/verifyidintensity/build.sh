#!/bin/bash

make CXX=${CXX} INCLUDES="-I. -I${PREFIX}/include -L${PREFIX}/lib" OPTFLAG="-O2 -DBOOST_BIND_GLOBAL_PLACEHOLDERS"

mkdir -p ${PREFIX}/bin
mv verifyIDintensity ${PREFIX}/bin/

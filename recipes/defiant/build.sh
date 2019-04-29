#!/bin/bash

export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
mkdir -p ${PREFIX}/bin

unzip defiant.zip

# Compile binaries
if [ `uname` == Darwin ]; then
    grep -v omp.h defiant.c | grep -v omp_ | grep -v pragma | sed 's/char \*restrict argv/char * argv/g' > defiant_mac.c
    ${CC} -o defiant defiant_mac.c -Wall -pedantic -std=gnu99 -lm -O3
else
    ${CC} -O4 -o defiant defiant.c -Wall -pedantic -std=gnu11 -lm -fopenmp
fi
mv regions_of_interest regions_of_interest.c
${CC} -o roi regions_of_interest.c -lm -Wall -std=gnu11 -Wextra -pedantic -Wconversion

# Copy binaries
cp defiant ${PREFIX}/bin/defiant
cp roi ${PREFIX}/bin/roi

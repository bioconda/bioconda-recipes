#!/bin/bash

unzip defiant.zip

# Compile binaries
${CC} -O4 -o defiant defiant.c -Wall -pedantic -std=gnu11 -lm -fopenmp
mv regions_of_interest regions_of_interest.c
${CC} -o roi regions_of_interest.c -lm -Wall -std=gnu11 -Wextra -pedantic -Wconversion

# Copy binaries
cp defiant ${PREFIX}/bin/defiant
cp roi ${PREFIX}/bin/roi

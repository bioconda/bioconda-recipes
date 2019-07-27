#!/bin/bash

mkdir -p ${PREFIX}/bin

# Compile main executables
if [ "$(uname)" == "Darwin" ]; then
    # clang doesn't work with -fopenmp
    export LDFLAGS="$LDFLAGS -L${PREFIX}/lib -lstdc++ -pthread"
else
    export LDFLAGS="$LDFLAGS -L${PREFIX}/lib -lstdc++ -pthread -fopenmp"
fi

make CC=$CC CXX=$CXX LDFLAGS="$LDFLAGS"

chmod +x CARNAC-LR 
chmod +x scripts/CARNAC_to_fasta
ls scripts
cp CARNAC-LR ${PREFIX}/bin/
cp scripts/CARNAC_to_fasta ${PREFIX}/bin/


# Copy scripts
chmod +x scripts/CARNAC_to_fasta.py
chmod +x scripts/paf_to_CARNAC.py
cp scripts/CARNAC_to_fasta.py ${PREFIX}/bin/CARNAC_to_fasta.py
cp scripts/paf_to_CARNAC.py ${PREFIX}/bin/paf_to_CARNAC.py

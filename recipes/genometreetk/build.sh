#!/bin/bash

# install python libraries
python -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

# copy main python script
chmod +x bin/genometreetk
cp bin/genometreetk ${PREFIX}/bin/

mkdir ${PREFIX}/genometreetk
cp genometreetk/VERSION ${PREFIX}/genometreetk

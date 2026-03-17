#!/bin/bash

mkdir -p $PREFIX/bin ${PREFIX}/share/sizemeup

# Install sizemup library
$PYTHON -m pip install --no-deps --ignore-installed -vv .

# move main executable, and replace with wrapper
chmod 755 bin/sizemeup-bioconda
mv $PREFIX/bin/sizemeup $PREFIX/bin/sizemeup-main
cp -f bin/sizemeup-bioconda $PREFIX/bin/sizemeup

# Copy genome size database (~100kb)
cp -f data/sizemeup-sizes.txt ${PREFIX}/share/sizemeup

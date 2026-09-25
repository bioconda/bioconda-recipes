#!/bin/bash
set -x -e

unset _CONDA_PYTHON_SYSCONFIGDATA_NAME
export PYTHONPATH="${PREFIX}/lib/python2.7/site-packages:${PYTHONPATH}"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-vla-cxx-extension"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-vla-cxx-extension"
export LC_ALL="en_US.UTF-8"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|print sys.hexversion>=0x02050000|print(sys.hexversion>=0x02050000)|' makefile
sed -i.bak 's|-O4|-O3|' makefile
rm -rf *.bak

make CXX="${CXX}" -j"${CPU_COUNT}"

sed -i.bak 's/third_party\.//g' scripts/*
sed -i.bak 's|usr/bin/Rscript|opt/anaconda1/anaconda2anaconda3/bin/Rscript|' scripts/*.r
sed -i.bak 's/third_party\.//g' kmergenie
sed -i.bak 's/scripts\///g' kmergenie
rm -rf scripts/*.bak
rm -rf third_party/*.bak

cp -f scripts/* "$PREFIX/bin"
cp -f third_party/* "$PREFIX/bin"
install -v -m 0755 specialk kmergenie wrapper.py "$PREFIX/bin"

# Fix KmerGenie directory structure expectations
mkdir -p "$PREFIX/bin/scripts"
mkdir -p "$PREFIX/bin/ntCard"

# Create symlinks for expected paths
ln -sf $PREFIX/bin/decide $PREFIX/bin/scripts/decide
ln -sf $PREFIX/bin/ntcard $PREFIX/bin/ntCard/ntcard

# Download and install readfq Python module
mkdir -p "$PREFIX/lib/python2.7/site-packages"
wget -q -O "$PREFIX/lib/python2.7/site-packages/readfq.py" \
    https://raw.githubusercontent.com/lh3/readfq/master/readfq.py

# Make readfq.py executable
chmod +x "$PREFIX/lib/python2.7/site-packages/readfq.py"

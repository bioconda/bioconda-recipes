#!/bin/bash
export CXXFLAGS="$CFLAGS -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
${PYTHON} installer.py ${PREFIX} --tool HyPlAs_bin --skip pandas numpy packaging platon spades racon minigraph minimap2
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
${PYTHON} -m pip install external/unicycler-modified-for-hyplas/ --no-deps --no-build-isolation --no-cache-dir -vvv

#!/bin/bash
export CXXFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
${PYTHON} installer.py ${PREFIX} --tool HyPlAs_bin --skip pandas numpy packaging platon spades racon minigraph minimap2
${PYTHON} -m pip install . --no-deps -vvv
${PYTHON} -m pip install external/unicycler-modified-for-hyplas/ --no-deps -vvv

#!/bin/bash

mkdir -p "${PREFIX}/bin"

# Install both the pairix binaries and the Python extension module
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make CC="${CC}" CFLAGS="${CFLAGS} -O3" INCLUDES="-I${PREFIX}/include" LIBPATH="-L${PREFIX}/lib" -j4

cp util/*.pl $PREFIX/bin/
cp util/*.sh $PREFIX/bin/
cp util/bam2pairs/bam2pairs $PREFIX/bin/

# Fix perl shebang
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/column_remover.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/duplicate_header_remover.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/fragment_4dnpairs.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/juicer_shortform2pairs.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/merged_nodup2pairs.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/old_merged_nodup2pairs.pl

cp bin/pairix $PREFIX/bin/
cp bin/pairs_merger $PREFIX/bin/
cp bin/streamer_1d $PREFIX/bin/

$PYTHON -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir

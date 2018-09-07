#!/usr/bin/env bash
set -x

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=$PREFIX/include

for make_file in libs/string_buffer/Makefile $(find libs/seq_file -name Makefile) $(find libs/seq-align -name Makefile) Makefile; do
    sed -i.bak 's/-lz/-lz $(LDFLAGS)/' $make_file
done


# 
make MAXK=31
make MAXK=63

sed -i.bak '1 s|^.*$|#!/usr/bin/env bash|g' bin/mccortex && rm bin/mccortex.bak

mkdir -p $PREFIX/bin
install -p bin/* $PREFIX/bin


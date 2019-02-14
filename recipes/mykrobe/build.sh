#!/bin/bash
set -x

export CFLAGS="-I$PREFIX/include -fPIC"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

# download phelim's fork of mccortex
MCCORTEX_DIR=mccortex
MCCORTEX_GIT="https://github.com/phelimb/mccortex"
mkdir "$MCCORTEX_DIR"
git clone --recursive -b geno_kmer_count "$MCCORTEX_GIT" "$MCCORTEX_DIR"

# remove LDFLAGS from mccortex dependencies
cd "$MCCORTEX_DIR"
sed -i.bak 's/LDFLAGS  =/#LDFLAGS  =/' libs/htslib/Makefile
for make_file in libs/string_buffer/Makefile $(find libs/seq_file -name Makefile) $(find libs/seq-align -name Makefile) $(find libs/htslib -name Makefile) Makefile; do
    sed -i.bak 's/-lz/-lz $(LDFLAGS)/' $make_file
done

make MAXK=31

mkdir -p $PREFIX/bin
install -p bin/mccortex31 $PREFIX/bin/

cd ../

"$PYTHON" -m pip install . --no-deps -vv
